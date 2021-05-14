use 5.006;
use strict;
use warnings;
use Module::Build;

$ENV{'PERL_MB_OPT'} = '--install-base=/usr'; # I could not make this work via the parameters below :/
$ENV{'DEB_BUILD_OPTIONS'}='nocheck';

use lib '../tm2_base/lib';
use lib '../templescript/lib';

my $debian = Module::Build->subclass(
    class => "Module::Build::Debian",
    code => <<'SUBCLASS' );

sub DEBVERSION {
    return 1;
}

sub ACTION_cpan_upload {
    my $self = shift;

    $self->depends_on("dist");
    my $version = $self->dist_version;
    $self->do_system(qq{   cpan-upload TM2::DuckDNS-${version}.tar.gz } );
}

sub ACTION_README {
    my $self = shift;

    $self->do_system(qq{   pod2readme -f markdown lib/TM2/DuckDNS.pm } );
}

sub ACTION_debian {
    my $self = shift;

    $self->depends_on("README");
    $self->depends_on("distdir");

    my $version = $self->dist_version;
    my $debversion = $self->DEBVERSION;
    $self->do_system(qq{   dh-make-perl --build --version=$version-$debversion TM2-DuckDNS-$version } );
}

sub ACTION_inject {
    my $self = shift;

    $self->depends_on("debian");

    my $version = $self->dist_version;
    my $debversion = $self->DEBVERSION;
    $self->do_system(qq{ scp libtm2-duckdns-perl_${version}-${debversion}_all.deb packages.devc.at:packages/ } );
    foreach (qw(stretch) ) { # squeeze wheezy jessie
        $self->do_system(qq{ ssh packages.devc.at -Y -t reprepro --ask-passphrase -b /var/www/packages/data/dists/ includedeb $_ packages/libtm2-duckdns-perl_${version}-${debversion}_all.deb })
;
    }
}
SUBCLASS

my $builder = $debian->new(
    module_name         => 'TM2::DuckDNS',
    license             => 'artistic_2',
    dist_author         => q{Robert Barta <rho@devc.at>},
    dist_version_from   => 'lib/TM2/DuckDNS.pm',
    release_status      => 'stable',
    configure_requires => {
             'Module::Build' => '0',
    },
    build_requires => {
 	    'Test::More' => 0,
	    'Net::DNS' => 0,
	    'Pod::Readme' => 0,
    },
    requires => {
	    'TM2::TempleScript' => 0,
	    'IO::Async::SSL' => 0,
    },
    add_to_cleanup     => [ 'TM2-DuckDNS-*' ],
    install_base        => '/usr',
    install_path        => { 'ontologies' => '/usr/share/templescript/ontologies',
    },
    onto_files          => {
        'ontologies/duckdns.ts' => 'ontologies/duckdns.ts'
    },
);

$builder->add_build_element('onto');
$builder->create_build_script();

