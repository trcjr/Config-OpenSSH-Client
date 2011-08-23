use Test::Most;
use Data::Dumper;
use FindBin;
use File::Find qw(find);

#use Smart::Comments;
use Config::OpenSSH::Client;
use Config::OpenSSH::Client::Entry;

ok(1);

#my $e = Config::OpenSSH::Client::Entry->new(
#    {
#        hosts    => ['fish', 'cat'],
#        options => { User => 'tom' }
#    }
#);
### E: $e->as_text

#warn Dumper $e;

done_testing;
