## Script to create a histogram plot of Global Active Power for the dates 2/1/07 and 2/2/07 from
## the Electric Power Consumption data included in the UC Irvine Machine Learning Repository

## This script assumes the following input data files are in the specified subfolders of the
## current working directory: (if not, it will download the source data to these directories)
##  - data/household_power_consumption.txt
##
## This script plots its output to the following file in the current working directory:
##  - plot1.png


## 1. Download source data to data directory if it doesn't already exist
fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
dataDir <- "data"
zipFile <- paste0(dataDir, "/exdata_data_household_power_consumption.zip")
dataFile <- paste0(dataDir, "/household_power_consumption.txt")
outputFile <- "plot1.png"

if (!file.exists(dataDir)) {
    dir.create(dataDir)
}

if (!file.exists(dataFile)) {
    if (!file.exists(zipFile)) {
        download.file(fileURL, zipFile, method="curl")
    }
    unzip(zipFile, exdir=dataDir)
}

## 1. Load the dataset for the date range: 2/1/2007 - 2/2/2007
library(sqldf)
data <- read.csv2.sql(dataFile, sql="select * from file where Date in ('1/2/2007', '2/2/2007')"
                      , header=TRUE, sep=";")


## 2. Convert Date and Time variables to Date/Time classes using strptime() and as.Date() functions
data$Time <- strptime(paste(data$Date, data$Time), format="%d/%m/%Y %H:%M:%S")
data$Date <- as.Date(data$Date, format="%d/%m/%Y")


## 3. Construct plot and save it to a PNG file with a width of 480 pixels and a height of 480 pixels
png(outputFile, width=480, height=480)  ## open the PNG device for plotting

## plot histogram of Global_active_power
hist(data$Global_active_power, col="red", main="Global Active Power", xlab="Global Active Power (kilowatts)")

dev.off()  ## close the PNG file device
