#include "stdio.h"

int after[9][9]={
// a b c d e f h i g
  {0,1,0,0,0,0,0,0,0}, // a
  {1,0,1,0,0,0,0,0,0}, // b
  {0,1,0,0,0,1,0,0,0}, // c
  {0,0,0,0,1,0,1,0,0}, // d
  {0,0,0,1,0,1,0,0,0}, // e
  {0,0,1,0,1,0,0,0,1}, // f
  {0,0,0,1,0,0,0,1,0}, // h
  {0,0,0,0,0,0,1,0,1}, // i
  {0,0,0,0,0,1,0,1,0}}; // g

int dfs(int x) {
  int y=0;
  if (x==6) { // h==6
    return 1;
  } else {
    for (y=0;y<=9;y++) {
      if (after[x][y]) {
        if (dfs(y)) {
          printf ("%i\n",y);
          break;
        }}}}} // плохой стиль!

int main(int argc, char ** argv) {
  if (dfs(0)) return 0;
  printf ("Нет решений\n");
  return 1;
}
