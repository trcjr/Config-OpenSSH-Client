#ABSTRACT: A module to interact with OpenSSH's client configuration
package Config::OpenSSH::Client;
use Moose;
use MooseX::AttributeShortcuts;
use autodie;
use Data::Dumper;
use File::Slurp;
use Config::OpenSSH::Client::Entry;

# VERSION

has [qw/ file_name content /] => (
    isa       => 'Str',
    is        => 'rw',
    required  => 0,
    predicate => 1,
);

has 'entries' => (
    isa      => 'ArrayRef',
    is       => 'rw',
    required => 0,
    lazy     => 1,
    default  => sub { [] }
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 1 && !ref $_[0] ) {
        return $class->$orig( file_name => $_[0], )
          if defined $_[0]
              && defined Cwd::abs_path( $_[0] )
              && -e Cwd::abs_path( $_[0] );
        return $class->$orig( content => $_[0], );
    }
    else {
        return $class->$orig(@_);
    }
};

sub BUILD {
    my $self = shift;
    my $args = shift;
    die "Can't specify content and file_name!"
      if $self->has_content && $self->has_file_name;

    #if ( $args->{Host} && $args->{options} ) {
    #    my $entry = Config::OpenSSH::Client::Entry->new(
    #        { Host => $args->{Host}, options => $args->{options} } );
    #    $self->add_entry($entry);
    #}
    #else {
    $self->_parse if $self->has_file_name || $self->has_content;

    #}
}

sub _parse {
    my $self = shift;

    $self->_parse_content( $self->content ) if $self->has_content;
    $self->_parse_file( $self->file_name )  if $self->has_file_name;
}

sub _parse_content {
    my $self    = shift;
    my $content = shift;

    my @lines = split "\n", $content;
    $self->_parse_lines( \@lines );
}

sub _parse_file {
    my $self      = shift;
    my $file_name = shift;
    die "Um, I can't read the file you gave me to parse!"
      unless ( -r $self->file_name );
    $self->_parse_lines( [ split( "\n", read_file $file_name) ] );
}

sub _parse_lines {
    my $self  = shift;
    my $lines = shift;

    my $items = {};
    my $current_host;
    my $entry;
    foreach (@$lines) {
        my ( $c, $d ) = /^\s*(\w+)\s+(.*)?/ or next;
        if ( $c =~ /Host$/i ) {
            $self->add_entry($entry) if $entry;
            $entry = Config::OpenSSH::Client::Entry->new();
            $entry->add_host($_) for split ' ', $d;
        }
        else {
            $entry->add_option( $c => $d );
        }
    }
    $self->add_entry($entry) if $entry;
}

sub add_entry {
    my $self  = shift;
    my $entry = shift;
    push @{ $self->entries }, $entry;
}

sub as_text {
    my $self = shift;
    my $output;
    foreach my $entry ( @{ $self->entries } ) {
        $output .= $entry->as_text;
    }
    return $output || '';
}

sub host_entry {
    my $self = shift;
    my $host = shift;
    foreach my $entry ( @{ $self->entries } ) {
        return $entry if grep { $_ eq $host } @{ $entry->hosts };
    }
    return undef;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 DESCRIPTION

An OO interface to working with with OpenSSH's client configuration files.

=head1 USAGE

   my $c = Config::OpenSSH::Client( file_name => '/etc/ssh/ssh_config' );
   print "Have an entry for some_host\n" if $c->entry_for_host('some_host');

=head1 METHODS

=head2 new ([$content | $file_name])

This method constructs a new Config::OpenSSH::Client object and parses
the content or file_name if provided.

=head2 as_text

Returns the contents of the configuration file.

=head2 host_entry( $entry )

Returns the L<Config::OpenSSH::Client::Entry> for the given host or undef if
there is no entry for the host.

=head2 add_entry( $entry )

Adds an entry.

=head2 BUILD

Called as part of Moose.

=cut
