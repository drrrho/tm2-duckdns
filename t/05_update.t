use strict;
use warnings;
use utf8;

use Data::Dumper;
use Test::More;
use Test::Exception;
use Test::Moose;

use Moose::Util qw( apply_all_roles );

use constant DONE => 1;

use TM2;
use TM2::TempleScript;
use TM2::Serializable::TempleScript;
use TM2::TS::Test;

my $warn = shift @ARGV;
unless ($warn) {
    close STDERR;
    open (STDERR, ">/dev/null");
    select (STDERR); $| = 1;
}

use TM2; # to see the $log
use Log::Log4perl::Level;
$TM2::log->level($warn ? $DEBUG : $ERROR); # one of DEBUG, INFO, WARN, ERROR, FATAL

sub _parse {
    my $t = shift;
    use TM2::Materialized::TempleScript;
    my $tm = TM2::Materialized::TempleScript->new (baseuri => 'tm:')
        ->extend ('TM2::ObjectAble')
        ->extend ('TM2::TriggerAble')
        ->extend ('TM2::ComfortAble')
        ->extend ('TM2::ImplementAble')
        ->extend ('TM2::Executable')
	;

    $tm->deserialize ($t);
    return $tm;
}

sub _mk_ctx {
    my $stm = shift;
    return [ { '$_'  => $stm, '$__' => $stm } ];
}

use TM2::TempleScript;
$TM2::TempleScript::Parser::UR_PATH = '/usr/share/templescript/ontologies/';

#===========================================================================================

# use constant TEST_DOMAIN => 'fwtest';
use constant TEST_DOMAIN => 'tm2-duckdns-test';
diag "testing subdomain ".TEST_DOMAIN;

if (DONE) {
    my $AGENDA = q{update: };

    use TM2::Materialized::TempleScript;
    my $duck = TM2::Materialized::TempleScript->new (file    => 'ontologies/duckdns.ts',
						     baseuri => 'ts:')
        ->extend ('TM2::ObjectAble')
        ->sync_in
        ;

    use IO::Async::Loop;
    my $loop = IO::Async::Loop->new;

    my $ctx = _mk_ctx (TM2::TempleScript::Stacked->new (orig => $duck) );
    $ctx = [ @$ctx, { '$loop' => $loop } ];

    throws_ok {
	TM2::TempleScript::return ($ctx, q{   ( "}.TEST_DOMAIN.q{" ) |->> duckdns:update ($env:DUCKDNS_WRONGTOKEN)   });
    } qr/token/, $AGENDA.'missing token';

#warn "RELEASE '$ENV{RELEASE_TESTING}'";

    if ($ENV{RELEASE_TESTING}) { # serious => DUCKDNS_TOKEN should be defined

	my $tss = TM2::TempleScript::return ($ctx, q{   ( "}.TEST_DOMAIN.q{" ) |->> duckdns:update ($env:DUCKDNS_TOKEN)   });
#warn Dumper $tss;
	like( $tss->[0]->[0]->[0], qr/ok/i, $AGENDA.'actually done');
	{
	    use Net::DNS;
	    my $res   = Net::DNS::Resolver->new;
	    my $reply = $res->search(TEST_DOMAIN.".duckdns.org", "A");

	    if ($reply) {
		my ($ip) = 
		    map { $_->address }
		    grep { $_->can("address") }
		    $reply->answer;

		like( $ip, qr/\d+\.\d+\.\d+\.\d+/, $AGENDA.'found IP address');

	    } else {
		ok(0, $AGENDA."query failed: ". $res->errorstring);
	    }
	}	
#--
	diag "sleeping for some time..."; sleep 5;
#-- wrong domain
	throws_ok {
	    $tss = TM2::TempleScript::return ($ctx, q{   ( "XXXX" ) |->> duckdns:update ($env:DUCKDNS_TOKEN)   });
#warn Dumper $tss;
	} qr/ko/i, $AGENDA.'wrong domain';
	diag $@;

#--
	diag "sleeping for some time..."; sleep 5;
#-- wrong token
	$ENV{DUCKDNS_TOKEN} = 'XXXX'; # ruin token
	throws_ok {
	    $tss = TM2::TempleScript::return ($ctx, q{   ( "}.TEST_DOMAIN.q{" ) |->> duckdns:update ($env:DUCKDNS_TOKEN)   });
#warn Dumper $tss;
	} qr/ko|error|bad/i, $AGENDA.'wrong token';
	diag $@;

    } else { # just fake
	ok (1, $AGENDA.'no RELEASE_TESTING, so live test skipped');
    }


# TODO; fail wrong domain
    
}

done_testing;

__END__

