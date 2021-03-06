# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v6.006.
use strict;
use warnings;

use 5.010000;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Public transport graphing",
  "AUTHOR" => "Erik Carlsson <info\@code301.com>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "Map-Metro",
  "LICENSE" => "perl",
  "MIN_PERL_VERSION" => "5.010000",
  "NAME" => "Map::Metro",
  "PREREQ_PM" => {
    "Eponymous::Hash" => 0,
    "File::ShareDir" => "1.102",
    "Graph" => "0.9704",
    "IO::Interactive" => 0,
    "List::Compare" => 0,
    "List::Util" => "1.45",
    "Module::Pluggable" => 0,
    "Moose" => "2.1803",
    "MooseX::App" => "1.29",
    "MooseX::AttributeDocumented" => "0.1003",
    "MooseX::AttributeShortcuts" => "0.028",
    "Path::Tiny" => "0.072",
    "PerlX::Maybe" => "1.001",
    "Safe::Isa" => "1.000005",
    "String::Trim" => 0,
    "Term::Size::Any" => 0,
    "Text::Undiacritic" => 0,
    "Throwable::SugarFactory" => 0,
    "Try::Tiny" => "0.24",
    "Types::Path::Tiny" => "0.005",
    "Types::Standard" => "1.000005",
    "XML::Writer" => 0,
    "namespace::autoclean" => "0.22"
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::More" => "0.96"
  },
  "VERSION" => "0.2406",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Eponymous::Hash" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::ShareDir" => "1.102",
  "File::Spec" => 0,
  "Graph" => "0.9704",
  "IO::Handle" => 0,
  "IO::Interactive" => 0,
  "IPC::Open3" => 0,
  "List::Compare" => 0,
  "List::Util" => "1.45",
  "Module::Pluggable" => 0,
  "Moose" => "2.1803",
  "MooseX::App" => "1.29",
  "MooseX::AttributeDocumented" => "0.1003",
  "MooseX::AttributeShortcuts" => "0.028",
  "Path::Tiny" => "0.072",
  "PerlX::Maybe" => "1.001",
  "Safe::Isa" => "1.000005",
  "String::Trim" => 0,
  "Term::Size::Any" => 0,
  "Test::More" => "0.96",
  "Text::Undiacritic" => 0,
  "Throwable::SugarFactory" => 0,
  "Try::Tiny" => "0.24",
  "Types::Path::Tiny" => "0.005",
  "Types::Standard" => "1.000005",
  "XML::Writer" => 0,
  "namespace::autoclean" => "0.22"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
