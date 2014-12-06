## Script to create a line plot of Global Active Power over time for the dates 2/1/07 and 2/2/07 from
## the Electric Power Consumption data included in the UC Irvine Machine Learning Repository

## This script assumes the following input data files are in the specified subfolders of the
## current working directory: (if not, it will download the source data to these directories)
##  - data/household_power_consumption.txt
##
## This script plots its output to the following file in the current working directory:
##  - plot2.png


## 1. Download source data to data directory if it doesn't already exist
fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
dataDir <- "data"
zipFile <- paste0(dataDir, "/exdata_data_household_power_consumption.zip")
dataFile <- paste0(dataDir, "/household_power_consumption.txt")
outputFile <- "plot2.png"

## create data directory if it doesn't already exist
if (!file.exists(dataDir)) {
    dir.create(dataDir)
}

## download and unzip data file if it doesn't already exist
if (!file.exists(dataFile)) {
    if (!file.exists(zipFile)) {
        download.file(fileURL, zipFile, method="curl")
    }
    unzip(zipFile, exdir=dataDir)
}

## 2. Load the dataset for the date range: 2/1/2007 - 2/2/2007

## I used read.csv2.sql at first because it was very simple and flexible, but it is much slower than
## using fread and it doesn't handle NA string replacement (e.g. na.strings argument), which could
## be a significant drawback depending on the dataset. As a result, I have rewritten this script using
## fread().

library(data.table)

## pass shell command to fread() to select only rows that begin with '1/2/2007' (d/m/Y) or '2/2/2007';
## read matching rows from shell command into a data.table, while replacing '?' in data with NA;
## make all columns of type character temporarily to handle potential '?' in data;
## we will change column types to appropriate types later.
strInput <- paste("grep '^[12]/2/2007'", dataFile)
data <- fread(strInput, header=FALSE, sep=";", na.strings="?", colClasses="character")

## get column names by reading in header row only from data file
## set column names of data.table to what we read from header row
colNames <- names(fread(dataFile, header=TRUE, sep=";", nrows=0))
setnames(data, colNames)


## 3. Convert Date and Time variables to Date/Time classes using as.Date() and strptime() functions
##    Convert numeric variables to numeric classes

## need to concatenate Date & Time variables before calling strptime() or the Date part will be today's date
## need to coerce time as POSIXct type because data.table will not support POSIXlt types
## convert columns 3-9 to be numeric type - ?s have already been converted to NA
data[, Time := as.POSIXct(strptime(paste(Date, Time), format="%d/%m/%Y %H:%M:%S"))]
data[, Date := as.Date(Date, format="%d/%m/%Y")]
data[, 3:9 := lapply(.SD, as.numeric), .SDcols=3:9, with=FALSE]


## 4. Construct plot and save it to a PNG file with a width of 480 pixels and a height of 480 pixels

png(outputFile, width=480, height=480)  ## open the PNG device for plotting

## plot Global_active_power variable versus Time as a line plot
with(data, plot(Time, Global_active_power, type="l", xlab="", ylab="Global Active Power (kilowatts)"))

dev.off()  ## close the PNG file device
