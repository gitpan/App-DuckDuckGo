package App::DuckDuckGo;
BEGIN {
  $App::DuckDuckGo::AUTHORITY = 'cpan:DDG';
}
{
  $App::DuckDuckGo::VERSION = '0.008';
}
# ABSTRACT: Application to query DuckDuckGo

use Moose;
use WWW::DuckDuckGo;

with qw(
	MooseX::Getopt
);

our $VERSION ||= '0.0development';

has duckduckgo => (
	metaclass => 'NoGetopt',
	isa => 'WWW::DuckDuckGo',
	is => 'ro',
	default => sub {
		my $self = shift;
		WWW::DuckDuckGo->new( http_agent_name => __PACKAGE__.'/'.$VERSION, forcesecure => $self->forcesecure );
	},
);

has query => (
	isa => 'Str',
	is => 'rw',
	predicate => 'has_query',
);

has batch => (
	isa => 'Bool',
	is => 'rw',
	default => sub { 0 },
);

has forcesecure => (
	isa => 'Bool',
	is => 'rw',
	default => sub { 0 },
);

has api => (
	isa => 'Str',
	is => 'ro',
	default => sub { 'zeroclickinfo' },
);

sub set_query_by_extra_argv {
	my ( $self ) = @_;
	$self->query(join(" ",@{$self->extra_argv})) if @{$self->extra_argv};
}

sub print_query_with_extra_argv {
	my ( $self ) = @_;
	$self->set_query_by_extra_argv;
	$self->print_query;
}

sub print_query {
	my ( $self ) = @_;
	return if !$self->has_query;
	my $api = $self->api;
	eval {
		my $result = $self->duckduckgo->$api($self->query);
		my $function = 'print_'.$self->api;
		$self->$function($result);
	};
	if ($@) {
		print ' _____ ____  ____   ___  ____'."\n";
		print '| ____|  _ \\|  _ \\ / _ \\|  _ \\'."\n";
		print '|  _| | |_) | |_) | | | | |_) |'."\n";
		print '| |___|  _ <|  _ <| |_| |  _ <'."\n";
		print '|_____|_| \\_\\_| \\_\\\\___/|_| \\_\\'."\n";
		print "\nAn error occured, we cant execute your query:\n\n";
		print " ".$@."\n";
		print "This is regulary not your fault, please try again later.\n";
		print "If the problem stay, please report on https://github.com/Getty/p5-app-duckduckgo/issues\n\n";
		exit 1;
	}
}

sub print_zeroclickinfo {
	my ( $self, $zci ) = @_;
	if ($self->batch) {
		print join("\n",$self->zeroclickinfo_batch_lines($zci))."\n";
	} else {
	
		print "\n";

        print "Redirected to: ".$zci->redirect."\n" if $zci->has_redirect;
		if ($zci->has_answer) {
			print "And the answer is:\n\n";
			print $zci->answer."\n\n";
			print "This answer was brought to you by '".$zci->answer_type."'. Fasten seat belts.\n\n";
		}
		
		my $heading;
		$heading = $zci->heading if $zci->has_heading;
		$heading .= " (".$zci->type_long.")" if $heading and $zci->has_type;
		print $heading."\n\n" if $heading;
	
		if ($zci->has_definition) {
			my $definition = $zci->definition if $zci->has_definition;
			$definition .= " (".$zci->definition_source.")" if $zci->has_definition_source;
			$definition .= "\nSource: ".$zci->definition_url->as_string if $zci->has_definition_url;
			print $definition."\n\n";
		}

		if ($zci->has_abstract_text) {
			my $abstract = $zci->abstract_text;
			$abstract .= " (".$zci->abstract_source.")" if $zci->has_abstract_source;
			$abstract .= "\nSource: ".$zci->abstract_url->as_string if $zci->has_abstract_url;
			print "Description: ".$abstract."\n\n";
		}
		
		if ($zci->has_default_related_topics) {
			print "Related Topics:\n";
			for (@{$zci->default_related_topics}) {
				if ($_->has_text or $_->has_first_url) {
					print " - ";
					print $_->text."\n" if $_->has_text;
					print "   " if $_->has_text and $_->has_first_url;
					print $_->first_url->as_string."\n" if $_->has_first_url;
				}
			}
			print "\n";
		}

		if (!$zci->has_default_related_topics and %{$zci->related_topics_sections}) {
			print "Related Topics Groups:\n";
			for (keys %{$zci->related_topics_sections}) {
				print "  Related Topics Groupname: ".$_."\n";
				for (@{$zci->related_topics_sections->{$_}}) {
					if ($_->has_text or $_->has_first_url) {
						print "   - ";
						print $_->text."\n" if $_->has_text;
						print "     " if $_->has_text and $_->has_first_url;
						print $_->first_url->as_string."\n" if $_->has_first_url;
					}
				}
			}
			print "\n";
		}
		
		if ($zci->results) {
			print "Other Results:\n";
			for (@{$zci->results}) {
				if ($_->has_text or $_->has_first_url) {
					print " - ";
					print $_->text."\n" if $_->has_text;
					print "   " if $_->has_text and $_->has_first_url;
					print $_->first_url->as_string."\n" if $_->has_first_url;
				}
			}
			print "\n";
		}
		
	}
}

sub zeroclickinfo_batch_lines {
	my ( $self, $zci ) = @_;
	my @lines;
	push @lines, "Abstract: ".$zci->abstract if $zci->has_abstract;
	push @lines, "AbstractText: ".$zci->abstract_text if $zci->has_abstract_text;
	push @lines, "AbstractSource: ".$zci->abstract_source if $zci->has_abstract_source;
	push @lines, "AbstractURL: ".$zci->abstract_url->as_string if $zci->has_abstract_url;
	push @lines, "Image: ".$zci->image->as_string if $zci->has_image;
	push @lines, "Heading: ".$zci->heading if $zci->has_heading;
	push @lines, "Answer: ".$zci->answer if $zci->has_answer;
	push @lines, "AnswerType: ".$zci->answer_type if $zci->has_answer_type;
	push @lines, "Definition: ".$zci->definition if $zci->has_definition;
	push @lines, "DefinitionSource: ".$zci->definition_source if $zci->has_definition_source;
	push @lines, "DefinitionURL: ".$zci->definition_url->as_string if $zci->has_definition_url;
	push @lines, "Type: ".$zci->type if $zci->has_type;
	if (%{$zci->related_topics_sections}) {
		push @lines, "RelatedTopicsSections:";
		for (keys %{$zci->related_topics_sections}) {
			push @lines, "  RelatedTopicsSection: ".$_;
			push @lines, $self->zeroclickinfo_batch_links_lines(@{$zci->related_topics_sections->{$_}});
		}
	}
	if ($zci->results) {
		push @lines, "Results:";
		push @lines, $self->zeroclickinfo_batch_links_lines(@{$zci->results});
	}
	return @lines;
}

sub zeroclickinfo_batch_links_lines {
	my ( $self, @links ) = @_;
	my @lines;
	for (@links) {
		push @lines, "    -- " if @lines;
		push @lines, "    Result: ".$_->result if $_->has_result;
		push @lines, "    FirstURL: ".$_->first_url->as_string if $_->has_first_url;
		push @lines, "    Text: ".$_->text if $_->has_text;
		if ($_->has_icon) {
			push @lines, "    Icon:";
			push @lines, $self->zeroclickinfo_batch_icon_lines($_->icon);
		}
	}
	return @lines;
}

sub zeroclickinfo_batch_icon_lines {
	my ( $self, $icon ) = @_;
	my @lines;
	push @lines, "      URL: ".$icon->url->as_string if $icon->has_url;
	push @lines, "      Width: ".$icon->width if $icon->has_width;
	push @lines, "      Height: ".$icon->height if $icon->has_height;
	return @lines;
}

1;


__END__
=pod

=head1 NAME

App::DuckDuckGo - Application to query DuckDuckGo

=head1 VERSION

version 0.008

=head1 SYNPOSIS

  use App::DuckDuckGo;
  App::DuckDuckGo->new_with_options->print_query_with_extra_argv;

=head2 DESCRIPTION

This is the class which is used by duckduckgo script to do the work. Please read L<duckduckgo> to get the documentation for the command line tool.

=head1 AUTHOR

Torsten Raudssus <torsten@raudssus.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by L<DuckDuckGo Inc.|https://duckduckgo.com/>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

