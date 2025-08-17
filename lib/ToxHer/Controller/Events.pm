package ToxHer::Controller::Events;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Catalyst::Request::Upload;
use Image::Magick;
use Data::FormValidator::Constraints qw(:closures);
use Date::Manip;

use Data::Dump;

=head1 NAME

ToxHer::Controller::Events - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto :Private

=cut

sub auto :Private {
    my ($self, $c) = @_;

    if ($c->check_user_roles('admin')) {
        $c->stash->{submenu} = 'events/menu';
    }
    return 1;
}

=head2 default :Private

=cut

sub default :Private {
    my ( $self, $c ) = @_;

    $c->forward( 'list' );
}

=head2 list :Local

Fetch all event objects and pass to events/list.tt2 in stash to be displayed.

=cut

sub list :Local {
    my ( $self, $c ) = @_;

    $c->stash(
        content_class => 'medium',
        list          => [ $c->model( 'DB::Event' )->search({}, {order_by => 'pubdate DESC'}) ],
        template      => 'events/list.tt2',
        title         => 'Events',
    );
}

=head2 view :Local

Show all details to the wanted event.

=cut

sub view :Local {
    my ( $self, $c, $id ) = @_;

    my $item = $c->model( 'DB::Event' )->find( $id );
    if ( !$item ) {
        $c->msg->store( 'There is no event with such an id.' );
        return $c->forward( 'list' );
    }

    my $pdf_data = $item->data;
    my $pdf_name = $item->filename;

    if ( !$pdf_data ) {
        $c->msg->store( 'Failed to retrieve PDF from database.' );
    } else {
        if ($pdf_name) {
            $pdf_name =~ s/\s//g;
            $pdf_name =~ s/Ü/Ue/g;
            $pdf_name =~ s/ü/ue/g;
            $pdf_name =~ s/Ä/Ae/g;
            $pdf_name =~ s/ä/ae/g;
            $pdf_name =~ s/Ö/Oe/g;
            $pdf_name =~ s/ö/oe/g;
            $pdf_name =~ s/&ndash;/-/g;
            $c->stash(pdf_name=>$pdf_name);

            my $temp_dir = $c->config->{root} . "/temp/";
            # Clean up older temporary files
            foreach (<$temp_dir/*>) {
                unlink $_;
            }

            ( my $file_name = $pdf_name ) =~ s/.pdf$//g;
            my $pdf_path = $temp_dir . $file_name . '.pdf';
            my $jpg_path = $temp_dir . $file_name . '.jpg';
            mkdir $temp_dir;
 
            open my $pdf_fh, '>', $pdf_path or die "Cannot open file $pdf_path: $!";
            binmode $pdf_fh;
            print $pdf_fh $pdf_data;
            close $pdf_fh;

            # Use Image::Magick to convert first page of the PDF to a JPG image
            my $image = Image::Magick->new;
            $image->Read($pdf_path . '[0]');  
            $image->Write($jpg_path);

            $c->stash(jpg_path=>$jpg_path);
            $c->stash(file_name=>$file_name);
        }
    }

    $c->stash(
        item         => $item,
        location     => $item->location,
        template     => 'events/view.tt2',
        popup        => 1,
        title        => 'Show event\'s details',
    );
}

=head2 create :Local

Display form to collect information for event to create.

=cut

sub create :Local {
    my ( $self, $c ) = @_;

    # $c->detach('/auth/denied') unless $c->check_user_roles('admin');

    $c->stash(
        content_class => 'medium',
        action        => 'create',
        template      => 'events/form.tt2',
        title         => 'Create a new event',
    );

    $c->stash->{locations} = [ $c->model( 'DB::Location' )->search( undef, {order_by => 'address'} ) ],
}

=head2 do_create :Local 

Take information from form and add to database.

=cut

sub do_create :Local {
    my ( $self, $c ) = @_;

    $c->forward('validate');

    if ($c->form->has_missing || $c->form->has_invalid) {
        $c->detach('create');
    }

    # Retrieve data from form
    my $location = $c->request->params->{location};
    my $upload   = $c->request->upload('file');

    # Create the event
    my $item = $c->model( 'DB::Event' )->create({
        title        => scalar $c->form->valid('title'),
        pubdate      => scalar UnixDate($c->form->valid( 'pubdate'), "%Y-%m-%d" ),
        source       => scalar $c->form->valid('source'),
        body         => scalar $c->form->valid('body'),
        filename     => $upload->filename,
        data         => $upload->slurp,
        content_type => $upload->type,
        location_id  => $location,
    });

    $c->stash(status_msg => 'New event with title "' . $item->title . ' has been filed.');
    $c->res->redirect( $c->uri_for( '/events/list' ) );
}

=head2 edit :Local

Display form for editing an event.

=cut

sub edit :Local {
    my ( $self, $c, $id ) = @_;

    $c->detach('/auth/denied') unless $c->check_user_roles('admin');

    if ( $c->stash->{item} = $c->model( 'DB::Event' )->find( $id ) ) {
        $c->stash(
            content_class => 'medium',
            action   => 'edit',
            form     => {
                title    => $c->stash->{item}->title,
                source   => $c->stash->{item}->source,
                body     => $c->stash->{item}->body,
                location => $c->stash->{item}->location->id,
            },
            locations => [ $c->model( 'DB::Location' )->search( undef, {order_by => 'address'} ) ],
            template  => 'events/form.tt2',
            title     => 'Edit Event',
        );
        $c->stash->{form}->{pubdate} = UnixDate( $c->stash->{item}->pubdate, "%d.%m.%Y" );
    }
    else {
        $c->stash(error_msg => 'There is no event with such an id.' );
        $c->forward( 'list' );
    }
}

=head2 do_edit :Local

Take information from form and change entry of database.

=cut

sub do_edit :Local {
    my ( $self, $c, $id ) = @_;

    $c->stash->{action} = 'edit';

    unless ( $c->stash->{item} = $c->model( 'DB::Event' )->find( $id ) ) {
        $c->stash->(error_msg => 'There is no event with such an id.');
        return $c->forward( 'edit' );
    }

    $c->forward( 'validate' );

    # Retrieve values from form
    my $location = $c->request->params->{location};
    my $upload   = $c->request->upload('file');

    unless ( $c->form->has_missing || $c->form->has_invalid ) {
        $c->stash->{item}->title( scalar $c->form->valid( 'title' ) );
        $c->stash->{item}->pubdate( scalar UnixDate ($c->form->valid( 'pubdate' ), "%Y-%m-%d") );
        $c->stash->{item}->source( scalar $c->form->valid( 'source' ) );
        $c->stash->{item}->body( scalar $c->form->valid( 'body' ) );
        $c->stash->{item}->filename( $upload->filename );
        $c->stash->{item}->data( $upload->slurp );
        $c->stash->{item}->content_type( $upload->type );
        $c->stash->{item}->location_id( $location );
        $c->stash->{item}->update;

        $c->stash->(status_msg => 'Data for event with title "' . $c->stash->{item}->title . '" has been changed.');
        $c->res->redirect( $c->uri_for( '/events/list' ) );
    }
    else {
       $c->detach('edit');
    }
}

=head2 delete :Local

Delete event and forward to list.

=cut

sub delete :Local {
    my ( $self, $c, $id ) = @_;

    $c->detach('/auth/denied') unless $c->check_user_roles('admin');

    if ( $c->stash->{item} = $c->model( 'DB::Event' )->find( $id ) ) {
        $c->stash(status_msg => 'Event "' . $c->stash->{item}->title . '" has been removed.');
        $c->stash->{item}->delete;
    }
    else {
        $c->stash(error_msg => 'There is no event with this id.' );
    }
    $c->forward( 'list' );
}

=head2 validate :Private

Validate form data.

=cut

sub validate :Private {
    my ($self, $c) = @_;

    my $dfv = {
        filters  => 'trim',
        required => [qw(title)],
        optional => [qw(pubdate source body)],
        constraint_methods => {
            pubdate => constraint_pubdate( $c, {fields => 'pubdate'} ),
        },
        validator_packages => __PACKAGE__,
        msgs => {
            constraints => {
                pubdate_valid => 'The format of the publication date is invalid.',
            },
            format => '%s',
        },
    };
    $c->form($dfv);
}

=head2 constraint_pubdate

=cut

sub constraint_pubdate {
    return sub {
        my $dfv = shift;
        my $data = $dfv->get_input_data;

        if ( $data->{pubdate} ne '' ) {
            $dfv->set_current_constraint_name('pubdate_valid');
            Date_Init("DateFormat=de");
            my $date = ParseDate($data->{pubdate});
            return $date eq '' ? 0 : 1;
        }

        return 1;
    }
}

sub convert_pdf_to_jpg {
    my ($c, $self, $pdf_blob) = @_;

    # Create a temporary file path for the PDF and JPG image
    my $temp_dir = $c->config->{root} . "/temp/";
    my $pdf_path = "${temp_dir}temp.pdf";

    # my $jpg_path = "${temp_dir}pdf_page.jpg";

    # Write the PDF BLOB to a temporary file
    # mkdir $temp_dir;
    # open my $pdf_fh, '>', $pdf_path or die "Cannot open file $pdf_path: $!";
    # binmode $pdf_fh;
    # print $pdf_fh $pdf_blob;
    # close $pdf_fh;

    # Use Image::Magick to convert the first page of the PDF to a JPG image
    # my $image = Image::Magick->new;
    # $image->Read($pdf_path . '[0]');  # Read the first page of the PDF
    # $image->Write($jpg_path);

    # return $jpg_path if -e $jpg_path;

    # return undef;
}

=encoding utf8

=head1 AUTHOR

Christian Kassung,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
