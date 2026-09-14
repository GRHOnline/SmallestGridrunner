#include <iostream>
#include <conio.h>
#include <fstream>
#include <vector>
#include <stdio.h> // used for simple file access!
#include "prettyfine.h"

int main()
{
    ofstream FyleSave;
    unsigned char cPattern = 0;
    int iGap = 0;
    int iNegative = 0;

    FILE * fReadme;
    FILE * fPrintme;
    string sGrab;
    int iTemp = 0;
    int iFound = 0;
    int iCounter = 0;
    int iErrors = 0;

    vector<int> viDatum;
    vector<int> viSorted;
    vector<int> viHeader;

    int iLocation[12] = {ERRORS_HEADER01, ERRORS_HEADER02, ERRORS_FILESIZE_LOW, ERRORS_FILESIZE_HIGH, ERRORS_OFFSET, ERRORS_WIDTH, ERRORS_PLANE, ERRORS_DEPTH, ERRORS_COMPRES01, ERRORS_COMPRES02,ERRORS_COMPRES03,ERRORS_COMPRES04};
    int iCmpValue[12] = {COMPARE_HEADER01, COMPARE_HEADER02, COMPARE_FILESIZE_LOW, COMPARE_FILESIZE_HIGH, COMPARE_OFFSET, COMPARE_WIDTH, COMPARE_PLANE, COMPARE_DEPTH, COMPARE_COMPRES01, COMPARE_COMPRES02, COMPARE_COMPRES03, COMPARE_COMPRES04};

    const char * cOut0 = "Grid.spr"; // our default output files
    const char * cOut1 = "PlayerShip.spr";
    const char * cOut2 = "PlayerBullet.spr";
    const char * cOut3 = "GridSearcher.spr";
    const char * cOut4 = "Numbers.spr";
    const char * cOut5 = "yZapper.spr";
    const char * cOut6 = "xZapper.spr";
    const char * cOut7 = "HorizontalLaser.spr";
    const char * cOut8 = "VerticalLaser.spr";
    const char * cOut9 = "Pods.spr";
    const char * cOutA = "DownMissile.spr";
    const char * cOutB = "PlayerExplosion.spr";
    const char * cIn = "SpritesMono.bmp"; // our default input file

    cout << "BMP to Gridrunner sprites (mono) converter." << endl;
    cout << "-------------------------------------------" << endl << endl;
    cout << "Convert an uncompressed 32 x 256 Monochrome BMP file into data files." << endl << endl;

//----------------------------------------------------------------------------- Load data in
    fReadme = fopen(cIn,"r");

    if ( fReadme == NULL )
    {
        iErrors+= ErrorWriter( cout , ERRORS_NOFILE);
        return 0;
    }

    while ( iFound == 0 )
    {
        cPattern = fgetc(fReadme);
        iFound = feof(fReadme);
        if ( iCounter < COMPARE_OFFSET ) viHeader.push_back(cPattern);
        else viDatum.push_back(cPattern);
        iCounter++;
    }

    fclose(fReadme);

// ------------------------------------------------ Check the header of the BMP header to see if it is correct.
    for ( iTemp = 0; iTemp < 12; iTemp++)
    {

        if ( viHeader.at(iLocation[iTemp]) != iCmpValue[iTemp])
        {
            iErrors+= ErrorWriter( cout, iLocation[iTemp]);
        }
    }

    cout << "Errors found " << iErrors << endl;
    if ( iErrors > 0 ) return 0;

//--------------------------------------------------- Sort data into a better format

    int iLoops = FONT_ROW;
    int iReverse = 0;

    for ( iTemp = 0; iTemp < (viDatum.size() - BIGGEST_INCREASE) ; iTemp++ )
    {
        //Flip our data upside down
        iReverse = COMPARE_IMAGE_SIZE -  iTemp;
        //Data is every 4 entries and is backwards!
        for ( iNegative = BIGGEST_INCREASE; iNegative >= 0 ; iNegative-= FONT_ROW)
        {
            viSorted.push_back( viDatum.at(iReverse+iNegative));
        }

        iLoops--;
        if (iLoops == 0) // Each symbol is 8 chars long. Track that here
        {
            iTemp+=BIGGEST_INCREASE;
            iLoops = FONT_ROW ;
        }

    }

//-------------------------------------------- copy back to the datum vector in chunks of 4 rows
    iNegative = 0;
    iLoops = 0;
    int iCombo = 24;

    for ( iTemp = 0; iTemp < viSorted.size(); iTemp++)
    {
        viDatum.at(iTemp) = viSorted.at(iCombo);
        iCombo ++;

        iLoops++;
        if ( iLoops == 8)
        {
            iLoops = 0;
            iCombo -= 16;

            iNegative++;
            if ( iNegative == 4 )
            {

                iNegative = 0;
                iCombo  = iTemp +  MAGIC_NUMBER ;
            }

        }

        if ( iCombo < 0 )
        {
            cout << "Minus zero swap location!" << endl;
            return 0;
        }

        if ( iCombo >= viSorted.size())
        {
            cout << "Swap location too high!" << endl;
            //return 0;
            iTemp = viSorted.size();
        }
    }

//------------------------------------------- Write our data files in order
    fPrintme = fopen(cOut0,"wb");

    iErrors = 0;
    if ( fPrintme == NULL )
    {
        iErrors+= ErrorWriter( cout , ERRORS_NOFILE);
        return 0;
    }

    iLoops = 0;
    for ( iGap=0; iGap<(FONT_SIZE*54);iGap+=(FONT_SIZE*2))
    {
        for ( iTemp=0; iTemp<FONT_SIZE;iTemp++)
        {
            fputc(viDatum.at(iGap+iTemp),fPrintme);
            fputc(viDatum.at(iGap+iTemp + FONT_SIZE),fPrintme);
        }
        iLoops++;
        if ( iLoops == 1)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut1,"wb");

        }
        if ( iLoops == 2)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut2,"wb");

        }
        if ( iLoops == 3)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut3,"wb");

        }
        if ( iLoops == 7)  //previous data entry ( Searchers ) has 4 entries
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut4,"wb");

        }
        if ( iLoops == 17)  //previous data entry ( Numbers ) has 10 entries
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut5,"wb");

        }
        if ( iLoops == 18)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut6,"wb");

        }
        if ( iLoops == 19)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut7,"wb");

        }
        if ( iLoops == 20)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut8,"wb");

        }

        if ( iLoops == 21)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOut9,"wb");

        }

        if ( iLoops == 25)  //previous data entry ( Pods ) has 4 entries
        {
            fclose(fPrintme);
            fPrintme = fopen(cOutA,"wb");

        }

        if ( iLoops == 26)
        {
            fclose(fPrintme);
            fPrintme = fopen(cOutB,"wb");

        }
    }
    fclose(fPrintme);

    return 0;
}

int ErrorWriter (std::ostream &Dumpfile , int iCode)
{
    if ( iCode == ERRORS_NOFILE ) Dumpfile << "Cannot open file! Check the file name! \nQuitting...." << endl;
    if ( iCode == ERRORS_HEADER01 ) Dumpfile << "Header incorrect! Should start with B " << endl;
    if ( iCode == ERRORS_HEADER02 ) Dumpfile << "Header incorrect! Second entry should be M " << endl;
    if ( iCode == ERRORS_FILESIZE_LOW ) Dumpfile << "File size ( low bit ) is incorrect." << endl;
    if ( iCode == ERRORS_FILESIZE_HIGH ) Dumpfile << "File size ( high bit ) is incorrect." << endl;
    if ( iCode == ERRORS_OFFSET ) Dumpfile << "Header/File offset is incorrect." << endl;
    if ( iCode == ERRORS_WIDTH ) Dumpfile << "Image width is incorrect." << endl;
    if ( iCode == ERRORS_PLANE ) Dumpfile << "Bit plane is incorrect." << endl;
    if ( iCode == ERRORS_DEPTH ) Dumpfile << "Bit depth is incorrect." << endl;
    if ( iCode == ERRORS_COMPRES01 ) Dumpfile << "Compression detected! First bit is not zero." << endl;
    if ( iCode == ERRORS_COMPRES02 ) Dumpfile << "Compression detected! Second bit is not zero." << endl;
    if ( iCode == ERRORS_COMPRES03 ) Dumpfile << "Compression detected! Third bit is not zero." << endl;
    if ( iCode == ERRORS_COMPRES04 ) Dumpfile << "Compression detected! Fourth bit is not zero." << endl;

    return 1;
}
