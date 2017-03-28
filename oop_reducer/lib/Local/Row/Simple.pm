package Local::Row::Simple; {

use strict;
use warnings;
use 5.10.0;

    sub parse_str {
        my $string = shift;
        my %params = ();        

        while ($string =~/(?<str>[\w:]+)/gc) {
            $_ = $+{str};
            my $temp_str = $+{str};
            my $count = s/://g;
            return undef if ($count != 1);

            $temp_str =~ /(\w+):(\w*)/g; 
            return undef if (!$2);

            $params{$1} = $2;                                
        }
        return \%params;
    }

    sub new {
        my ($class, %params) = @_;

        return undef if (!parse_str($params{str}));
        return bless parse_str($params{str}), $class;
    }

    sub get {
        my ($self, $name, $default) = @_;
     
        return $self->{$name} if (exists $self->{$name});
        return $default;
    }

}


1;
