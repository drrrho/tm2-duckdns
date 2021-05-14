#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

my $min_tcm = 0.9;
eval "use Test::CheckManifest $min_tcm";
plan skip_all => "Test::CheckManifest $min_tcm required" if $@;

ok_manifest({filter => [qr/\.git/, qr/junk/, qr/TM2-DuckDNS/, qr/_.*/, qr/ignore/, qr/token/, qr/.*\.(deb|sh|bak|gz)/, qr/~$/]});
