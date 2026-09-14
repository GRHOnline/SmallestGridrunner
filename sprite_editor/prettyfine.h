
#define FONT_ROW 4
#define FONT_SIZE 8
#define BIGGEST_INCREASE 28
#define COMPARE_IMAGE_SIZE 995

#define COMPARE_HEADER01 66
#define COMPARE_HEADER02 77
#define COMPARE_FILESIZE_LOW 62
#define COMPARE_FILESIZE_HIGH 4
#define COMPARE_OFFSET 62
#define COMPARE_WIDTH 32
#define COMPARE_PLANE 1
#define COMPARE_DEPTH 1
#define COMPARE_COMPRES01 0
#define COMPARE_COMPRES02 0
#define COMPARE_COMPRES03 0
#define COMPARE_COMPRES04 0

// using the location as the error code as well since it's a unique number.
#define ERRORS_HEADER01 0
#define ERRORS_HEADER02 1
#define ERRORS_FILESIZE_LOW 2
#define ERRORS_FILESIZE_HIGH 3
#define ERRORS_OFFSET 10
#define ERRORS_WIDTH 18
#define ERRORS_PLANE 26
#define ERRORS_DEPTH 28
#define ERRORS_COMPRES01 30
#define ERRORS_COMPRES02 31
#define ERRORS_COMPRES03 32
#define ERRORS_COMPRES04 33
//Other errors
#define ERRORS_TOO_BIG 34
#define ERRORS_TOO_SMALL 35
#define ERRORS_NOFILE 36

#define MAGIC_NUMBER 25 // 24 plus one. I think, I forgot how I arrived at this :(
#define NEW_LOOP 16

int ErrorWriter (std::ostream &Dumpfile , int iCode);


using namespace std;
