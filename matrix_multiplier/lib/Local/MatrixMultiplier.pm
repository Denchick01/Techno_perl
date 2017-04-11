package Local::MatrixMultiplier;

use strict;
use warnings;
use POSIX;
use 5.10.0;
use JSON::XS;
use DDP;

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];

    die "Invalid matrix size" if (@{$mat_a} != @{$mat_b});

    my $matrix_size = scalar @{$mat_a};

    for (my $it = 0; $it < $matrix_size; ++$it) {
        if (@{$mat_a->[$it]} != $matrix_size &&  @{$mat_b->[$it]} != $matrix_size) {
            die "Invalid matrix size" 
        }
    }
    
    $max_child = $matrix_size if ($max_child > $matrix_size);

    $|=1;
    my (@read, @write);
    my $step = $matrix_size/$max_child;
    my ($begin, $end) = (0, ceil($step));
 
    for (my $m = 0; $m < $max_child; $m++) {
        pipe($read[$m], $write[$m]);

        my $r = $read[$m];
        my $w = $write[$m];

        if(my $pid = fork()){
            close($w);
        }
        else {
           close($r);

            for (my $column_num = $begin; $column_num < $end; ++$column_num) {
                for (my $line_num = 0; $line_num < $matrix_size; ++$line_num) {
                    for (my $k = 0; $k < $matrix_size; ++$k) {
                        $res->[$column_num - $begin][$line_num] += $mat_a->[$k][$line_num] * $mat_b->[$column_num][$k];
                    }
                }
            }
                        
           my $json_xs = JSON::XS->new(); 
           $json_xs->ascii(1);
          
           say $json_xs->encode($res); 
           print $w $json_xs->encode($res);
           close($w);
           exit;
       }

    $begin += $step;
    
    $step = $matrix_size - $end if (($matrix_size - $end) < $step);
    $end += $step;

    }  

   waitpid(-1, 0);
 
   for my $fh (@read) {
       while(<$fh>){ 
           my $json_xs = JSON::XS->new();
           $json_xs->utf8(1);
           my $temp_res = $json_xs->decode($_);
           for my $m_column (@{$temp_res}) {
               push @{$res}, $m_column;
           } 
       } 

       close($fh);
   }

    return $res;
}

1;
