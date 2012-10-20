
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Application to query DuckDuckGo",
  "AUTHOR" => "Torsten Raudssus <torsten\@raudssus.de>",
  "BUILD_REQUIRES" => {
    "Test::More" => "0.96"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-DuckDuckGo",
  "EXE_FILES" => [
    "bin/duckduckgo"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::DuckDuckGo",
  "PREREQ_PM" => {
    "Moose" => "1.24",
    "MooseX::Getopt" => "0.35",
    "WWW::DuckDuckGo" => "0.004"
  },
  "VERSION" => "0.007",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



