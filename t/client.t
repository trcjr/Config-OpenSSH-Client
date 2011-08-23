use Test::Most;
use Data::Dumper;
use FindBin;
use File::Find qw(find);
use Config::OpenSSH::Client;
use Config::OpenSSH::Client::Entry;

my @ssh_config_files;
my $case_data_dir = "$FindBin::Bin/test_case_data";
find sub {
    push @ssh_config_files, $File::Find::name
      if /ssh_config/;
}, $case_data_dir;

my $ssh_config_file = pop @ssh_config_files;

my $content = <<CONTENT;
Host *
    ForwardX11 no
Host host1 host2
    Hostname %h.example.com
    User root
CONTENT
my $expect = {
    'Host' => {
        'Hostname'   => '*',
        'ForwardX11' => 'no'
    }
};

my $c;

lives_ok {
    Config::OpenSSH::Client->new();
}
'Lives when called with no arguments';

$c = Config::OpenSSH::Client->new( file_name => $ssh_config_file );
is $c->as_text, $content, "lossless conversion from file_name";


$c = Config::OpenSSH::Client->new( content => $content );
is $c->as_text, $content, "lossless conversion from content";
ok $c->host_entry('host1'), "Has an entry for 'host1'";
is $c->host_entry('host5') => undef, "no entry for 'host5'";

chmod 0000, $ssh_config_file;
dies_ok {
    Config::OpenSSH::Client->new( file_name => $ssh_config_file );
}
'Died parsing an unreadable file';
chmod 0644, $ssh_config_file;

dies_ok {
    Config::OpenSSH::Client->new(
        file_name => $ssh_config_file,
        content => $content
    );
}
'Died when given file_name and content';

$c = Config::OpenSSH::Client->new( content => "");
is $c->as_text, "", "New from empty content";

done_testing;
