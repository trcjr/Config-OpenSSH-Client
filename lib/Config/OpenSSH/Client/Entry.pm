#ABSTRACT: An OpenSSH::Client::Entry object
package Config::OpenSSH::Client::Entry;
use Moose;
use Data::Dumper;

# VERSION

has 'hosts' => (
    isa       => 'ArrayRef',
    is        => 'rw',
    required  => 0,
    predicate => 'has_hosts',
    lazy      => 1,
    default   => sub { [] }
);

has 'options' => (
    isa      => 'ArrayRef',
    is       => 'rw',
    required => 0,
    lazy     => 1,
    default  => sub { [] }
);

sub add_host {
    my $self = shift;
    my $host = shift;
    push @{ $self->hosts }, $host;
}

sub add_option {
    my ( $self, $name, $value ) = @_;
    push @{ $self->options }, { $name => $value };
}

# I don't like how this is done, maybe I'll fix it later...
sub as_text {
    my $self = shift;
    my @output;
    push @output, 'Host ' . join ' ', @{ $self->hosts };
    for my $option ( @{ $self->options } ) {
        while ( my ( $key, $value ) = each(%$option) ) {
            push @output, "    $key $value";
        }
    }
    return join "\n", ( @output, "" );
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 DESCRIPTION

An entry in a ssh_config

=head1 USAGE

   my $c = Config::OpenSSH::Client( file_name => '/etc/ssh/ssh_config' );
   print "Have an entry for some_host\n" if $c->entry_for_host('some_host');

=head1 METHODS

=head2 new ([$content | $file_name])

This method constructs a new Config::OpenSSH::Client object and parses
the content or file_name if provided.

=head2 as_text

Returns the contents of the configuration file.

=head2 add_host( $host )

Adds host to the entry, entries can have multiple hosts.

=head2 add_option( $name, $value )

Adds an option with the $name and $value to an entry.

=cut
