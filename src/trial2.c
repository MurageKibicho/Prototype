#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>


char* get_forecast()
{
    char* forecast = "sunny";
    char* forecast_m = malloc(strlen(forecast));
    strcpy(forecast_m, forecast);
    return forecast_m;
}

int SaveToFile(char *filePath)
{
    FILE *fp = fopen(filePath, "w");
    if(fp == NULL)
    {
        return 0;
    }
    else
    {
        int c = 0;
        char string[10] = "abcdefghi\0";
        fprintf(fp,"%s",string);
        fclose(fp);
        return 1;
    }
}

double get_temperature()
{
    return cos(86.0f);
}

double fahrenheit_to_celsius(double temperature)
{
  return (5.0f / 9.0f) * (temperature - 32);
}

