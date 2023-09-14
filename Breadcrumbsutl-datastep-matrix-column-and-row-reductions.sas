%let pgm=utl-datastep-matrix-column-and-row-reductions;

Problem
   Using datastep matrix operations to calculate chiSq expected counts

Two new FCMP row reduction matrix operations (see end of message)

  Suppose we have datastep array 'array ary[2,3]  xy1-xy(row*column)'

 1  mat(ary, row, .) -> if row=1 then sum of row 1 in APL ary[1,+)
 2  mat(ary, ., col) -> if col=1 then sum of col 1 in APL ary[+,1)


github
https://tinyurl.com/38nd73p7
https://github.com/rogerjdeangelis/utl-datastep-matrix-column-and-row-reductions


/**************************************************************************************************************************/
/*                 |                                                  |                                                   */
/*      INPUT      |   RULE EXAMPLE CHISQ EXPECTED VALUE EXP[1,1]     |   OUTPUT CHISQ (OBSERVED AND EXPECTED VALUES)     */
/*                 |                                                  |                                                   */
/*      y1  y2  y3 |                                                  |   CNT  EXPECT   CNT  EXPECT  CNT   EXPECT         */
/*                 |                                                  |                                                   */
/*  x1  11  12  13 |   (11+12+13)*(11+21)/(11+12+13+21+22 +23)=11.29* |    11   11.29*   12    12     13   12.70          */
/*                 |   or mat(1,+)*mat(+,1)/mat(+,+)                  |                                                   */
/*  x2  21  22  23 |                                                  |    21   20.70    22    22     23   23.29          */
/*                 |                                                  |                                                   */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

%let numSlots=6;

data sd1.have;
  input xy1-xy&numSlots @@;
cards4;
11 12 13
21 22 23
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.HAVE total obs=1                                                                                                   */
/*                                                                                                                        */
/* Obs    XY1    XY2    XY3    XY4    XY5    XY6                                                                          */
/*                                                                                                                        */
/*  1      11     12     13     21     22     23                                                                          */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

libname sd1 "d:/sd1";

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

data  sd1.want;

  set sd1.have;

  array ary[2,3]  xy:;
  array exps[3] $24 exp1-exp3;

  grandtot = sum(of ary[*]);

  do row=1 to dim(ary,1);
     do col=1 to dim(ary,2);
        /*--- expected = ary[row,+]*ary[+,col]/ary[+,+]                  ----*/
        exps[col] = catx(" ",ary[row,col], mat(ary, row, .)*mat(ary, ., col)/grandtot);
     end;
     output;
  end;

  keep row exp:;
  stop;

run;quit;

proc print data=sd1.want;
run;quit;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/


/**************************************************************************************************************************/
/*                                                                                                                        */
/*  SD1.WANT                                                                                                              */
/*                                                                                                                        */
/*  Obs  ROW       EXP1          EXP2          EXP3                                                                       */
/*                                                                                                                        */
/*   1    1   11 11.294117647    12 12    13 12.705882353                                                                 */
/*   2    2   21 20.705882353    22 22    23 23.294117647                                                                 */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*__
 / _| ___ _ __ ___  _ __
| |_ / __| `_ ` _ \| `_ \
|  _| (__| | | | | | |_) |
|_|  \___|_| |_| |_| .__/
                   |_|
*/

proc datasets lib=work kill nolist nodetails; run;quit;

* works;
proc fcmp outlib=work.userfuncs.ex;
  function mat(arr[*,*],r,c) ;
   tot=0;
   select;
     when (not missing(r) and missing(c)) do;
          do y = 1 to dim(arr,2);
            tot = sum(tot, arr[r,y]);
          end;
     end;
     when (missing(r) and not missing(c)) do;
          do x = 1 to dim(arr,1);
            tot = sum(tot, arr[x,c]);
          end;
     end;
     otherwise tot=.;
    end;
    return(tot);
  endsub;
run;quit;

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
