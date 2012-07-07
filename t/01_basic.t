#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use Boost::Geometry::Utils qw(polygon_multi_linestring_intersection
                              point_within_polygon
                              linestring_simplify);

{
    my $square = [  # ccw
        [10, 10],
        [20, 10],
        [20, 20],
        [10, 20],
    ];
    my $hole_in_square = [  # cw
        [14, 14],
        [14, 16],
        [16, 16],
        [16, 14],
    ];
    my $polygon = [$square, $hole_in_square];
    my $linestring = [ [5, 15], [30, 15] ];
    my $linestring2 = [ [40, 15], [50, 15] ];  # external
    my $multilinestring = [ [ [5, 15], [30, 15] ], [ [40, 15], [50, 15] ] ];
    
    {
        my $intersection =
            polygon_multi_linestring_intersection($polygon, [$linestring]);
        is_deeply $intersection, [
            [ [10, 15], [14, 15] ],
            [ [16, 15], [20, 15] ],
        ], 'line is clipped to square with hole';
    }
    {
        my $intersection =
            polygon_multi_linestring_intersection($polygon, [$linestring2]);
        is_deeply $intersection, [], 'external line produces no intersections';
    }
    {
        my $intersection =
            polygon_multi_linestring_intersection($polygon, $multilinestring);
        is_deeply $intersection, [
            [ [10, 15], [14, 15] ],
            [ [16, 15], [20, 15] ],
        ], 'multiple linestring clipping';
    }

    {
        my $point_in = [11,11];
        my $point_out = [8,8];
        my $point_in_hole = [15,15];
        ok point_within_polygon($point_in, $polygon), 'point in polygon';
        ok !point_within_polygon($point_out, $polygon), 'point outside polygon';
        ok !point_within_polygon($point_in_hole, $polygon),
            'point in hole in polygon';
        my $hole = [$hole_in_square];
        ok point_within_polygon($point_in_hole, $hole), 'point in hole';
    }

    {
        my $line = [[1.1, 1.1], [2.5, 2.1], [3.1, 3.1], [4.9, 1.1], [3.1, 1.9]];
        my $simplified = linestring_simplify($line, 0.5);
        is_deeply $simplified,
            [ [1.1, 1.1], [3.1, 3.1], [4.9, 1.1], [3.1, 1.9] ],
            'linestring simplification';
    }
}

__END__
