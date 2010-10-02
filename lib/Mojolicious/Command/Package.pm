#ABSTRACT:Include the Mojo library in you application!
package Mojolicious::Command::Package;
BEGIN {
  $Mojolicious::Command::Package::VERSION = '0.02';
}

use strict;
use warnings;


use Cwd;
use File::Find;
use File::Copy;
use base 'Mojo::Command';

__PACKAGE__->attr(description => <<'EOF');
Copy mojo and mojolicious libraries into your application making it self-contained.
EOF
__PACKAGE__->attr(usage => <<"EOF");
usage: $0 package [NAME]
or
usage: $0 package [NAME] verbose
EOF

# C'mon People, let catch up with the rest of the world. Bundled Libraries :}

sub run {
    our ($self, $class, $verbose) = @_;
    our ($cwd, $mojo, $mojox, $mojolicious, $base) = (getcwd());
    $class ||= 'MyMojoApp';
    
    # first things first, where are we?
    exit print "Sorry, can't find the application `$class`" unless
        -d -w $class && -d -w "$class/lib";
    
    foreach my $lib (@INC) {
        
        if (-d -r "$lib/Mojo" && -d -r "$lib/Mojolicious") {
            ($mojo, $mojox, $mojolicious, $base) =
                ("$lib/Mojo", "$lib/MojoX", "$lib/Mojolicious", $lib);
            
            find( \&_find_modules, $mojo);
            find( \&_find_modules, $mojox);
            find( \&_find_modules, $mojolicious);
            
            # grab the other little guys stranded out there
            foreach my $file (qw/Mojo.pm Mojolicious.pm/) {
                
                my $fle = "$cwd/$class/lib/$file";
                my $rlf = "$class/lib/$file";
                my $rld = "$class/lib";
                
                mkdir "$cwd/$rld";
                
                _death( '-r', $file )   unless -r "$lib/$file";
                _death( '-w', "$rld" ) unless -w "$cwd/$rld";
                
                print 'verbose' eq lc lc $verbose ?
                    "  [fetch] $fle\n  [write] to\t$cwd/$rlf\n" :
                    "  [write] $cwd/$rlf\n";
                copy("$lib/$file","$fle") or die "* copying $rlf failed: $!";
                
                chmod 0744, "$cwd/$rlf";
            
            }
            
            return
                print
                    "Mojolicious libraries have been copied to you ".
                    "application's local-library.";
        }
        
    }
    
    sub _find_modules {
        my $fle = $File::Find::name;
        my $dir = $File::Find::dir;
        my $rlf = $fle;
        my $rld = $dir;
        
        return unless $fle && $dir;
        
        $rlf =~ s/^$base\/?//;
        $rld =~ s/^$base\/?//;
        
        $rlf = "$class/lib/$rlf";
        $rld = "$class/lib/$rld";
        
        if (-f $fle ) {
            if ( $rlf =~ /.pm$/ || $rlf =~ /.pod$/ ) {
                
                mkdir "$cwd/$rld";
                
                _death( '-r', $fle )   unless -r $fle;
                _death( '-w', "$rld" ) unless -w "$cwd/$rld";
                
                print 'verbose' eq lc lc $verbose ?
                    "  [fetch] $fle\n  [write] to\t$cwd/$rlf\n" :
                    "  [write] $cwd/$rlf\n";
                copy($fle,"$cwd/$rlf") or die "* copying $rlf failed: $!";
                
                chmod 0744, "$cwd/$rlf";
            }
            else {
                print "// not copied, whats this - $rlf\n";
            }
        }
    }
    
    sub _death {
        my ($why, $what) = @_;
        my $explain = { '-r' => 'not readable', '-w' => 'not writable' };
        exit print "Sorry, the file $what was $explain->{$why}.";
    }
    
    exit print "Sorry, can't find the Mojolicious libraries in " .
        join ', ', @INC;
}

1;

__END__
=pod

=head1 NAME

Mojolicious::Command::Package - Include the Mojo library in you application!

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    use Mojolicious::Command::Package;

    my $generator = Mojolicious::Command::Package->new;
    $generator->run(@ARGV);

=head1 DESCRIPTION

This command finds your Mojo and Mojolicious installations and includes their
files in your application's local-library making your application self-contained.

=head1 ATTRIBUTES

L<Mojolicious::Command::Package> inherits all attributes from
L<Mojolicious::Command> and implements the following new ones.

=head2 C<description>

    my $description = $app->description;
    $app            = $app->description('Foo!');

Short description of this command, used for the command list.

=head2 C<usage>

    my $usage = $app->usage;
    $app      = $app->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Command::Package> inherits all methods from L<Mojolicious::Command>
and implements the following new ones.

=head2 C<run>

    $app = $app->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=head1 AUTHOR

Al Newkirk <awncorp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by awncorp.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

