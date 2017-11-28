#######
# Prepares acoustic features (MFCCs) for use in the "urban sounds challenge", a
# smaller version of the challenge at 
# 


# load required packages
library(seewave)
library(tuneR)
library(gtools)

# this file contains the response variable, indicating what sound each file contains
soundtypes <- read.csv("data/urbansounds/soundtypes.csv")

# check the distribution of sound types: its even across classes, good!
table(soundtypes$Class)

# read in filenames of audio files
nam <- mixedsort(list.files(path = "data/urbansounds/sounds/"))

# how many files do we have?
nfiles <- length(nam)
nfiles

#############################
## Explore the data
#############################

# what's the name of the first file in the directory containing the wav files?
nam[1]

# let's read in that sound file, the "from" and "units" options are needed, but just to show
sound = readWave(paste0("data/urbansounds/sounds/",nam[1]), from = 0, units="seconds")

# what sound type is this?
soundtypes$Class[1]

# check what the object contains
str(sound)

# plot the oscillogram (amplitude vs time). Note the two channels
plot(sound)

# this works out the length of time of the sound file (number of obs / sampling rate)
176400 / sound@samp.rate

# extract the left channel only, and turn this into a "Wave" file (what the tuneR package uses)
soundL <- Wave(sound@left, samp.rate = sound@samp.rate, bit = sound@bit)

# frequency spectrum shows the relative amplitude at different frequencies
spec(soundL, wl = 512)
# power spectrum is the square of the frequency spectrum, shows distribution of power across 
# different frequency components
spec(soundL, wl = 512, PSD = T)
# mean frequency spectrum
meanspec(soundL, wl=512)
# spectrogram
spectro(soundL, collevels = seq(-40,0,1))
# spectrogram messes up plot window, so have to reset it
dev.off()

#### Let's do another sound file

# read in file
sound <- readWave(paste0("data/urbansounds/sounds/",nam[2]))

# what sound type is this?
soundtypes$Class[2]

# check what the object contains
str(sound)

# plot the oscillogram (amplitude vs time)
plot(sound)

# this works out the length of time of the sound file (number of obs / sampling rate)
176400 / sound@samp.rate

# extract the left channel only, and turn this into a "Wave" file (what the tuneR package uses)
soundL <- Wave(sound@left, samp.rate = sound@samp.rate, bit = sound@bit)

# frequency spectrum shows the relative amplitude at different frequencies
spec(soundL, wl = 512)
# power spectrum is the square of the frequency spectrum, shows distribution of power across 
# different frequency components
spec(soundL, wl = 512, PSD = T)
# mean frequency spectrum
meanspec(soundL, wl=512)
# spectrogram
spectro(soundL, collevels=seq(-40,0,1))
# clear plot window
dev.off()

#### One last file

sound <- readWave(paste0("data/urbansounds/sounds/",nam[3]))
soundtypes$Class[3]
plot(sound)
soundL <- Wave(sound@left, samp.rate = sound@samp.rate, bit = sound@bit)
spec(soundL, wl = 512)
meanspec(soundL, wl = 512)
spectro(soundL, collevels=seq(-40,0,1))
dev.off()

# Our wav file has a 16-bit depth, meaning sound pressure values are mapped to 
# integers from -2^15 to (2^15)-1. We normalize these values to lie between -1 to 1
soundL_std <- soundL / 2^(soundL@bit - 1)

# Mel frequency cepstral coefficients are often good default features for audio
# classification problems

# Computes MFCCs within each of a number of overlapping windows, controlled by
# wintime and hoptime parameters, see ?melfcc
mfccs <- melfcc(soundL_std, wintime = 0.025, hoptime = 0.01)

# We can average over the windows if we want to get a single set of features per sound 
# although this loses a bunch of information
avg_mfccs <- apply(mfccs, 2, mean)

########################################################
# Let's compute the MFCCs for each audio file. We can 
# use the resulting features to build a classifier
########################################################

all_mfccs <- c()
n_mfccs <- c()
avg_mfccs <- c()
soundtype <- c()
failed_files <- c()
for(iter in 1:nfiles){
  
  ## progress bar of sorts
  print(paste(nam[iter],"start"))
  
  ## read in audio file
  sound = readWave(paste0("data/urbansounds/sounds/", nam[iter]))

  # check to see if there is a left channel, if not then exclude (not ideal)
  isLeft <- try(Wave(sound@left, samp.rate = sound@samp.rate, bit = sound@bit), TRUE)
  
  if(class(isLeft) != "try-error"){

  ## extract left channel  
  soundL <- Wave(sound@left, samp.rate = sound@samp.rate, bit = sound@bit)
     
     # standardize amplitude
     soundL_std <- soundL / 2^(soundL@bit -1)
     
     # extract MFCCs in each 25ms window (stepping 0.01 between windows)
     this_mfccs <- melfcc(soundL_std)
     # keep track of how many rows were created (for adding the response var later)
     n_mfccs <- c(n_mfccs, nrow(this_mfccs))
     
     # average over all windows
     this_avg_mfccs <- apply(this_mfccs, 2, mean)
     
     # keep track of all the MFCCs (i.e. within each window)
     all_mfccs <- rbind(all_mfccs, this_mfccs)
     
     # keep track of the average MFCCs (i.e. over all windows)
     avg_mfccs <- rbind(avg_mfccs, this_avg_mfccs)
     
  } else { failed_files <- c(failed_files, iter)}
  
  }

# extract the Class (sound type) information for those files that worked
soundtypes_completed <- soundtypes[-failed_files,]
id_completed <- soundtypes[-failed_files, 1]

# put into data frame, can ignore warning about row names
urbansounds_all <- data.frame(mfccs = all_mfccs, 
                              id = rep(id_completed$, times = n_mfccs)
                              y = rep(soundtypes_completed$Class, times = n_mfccs))

# put into data frame, can ignore warning about row names
urbansounds_avg <- data.frame(mfccs = avg_mfccs, y = soundtypes_completed$Class)

# save the two data frames above
save(urbansounds_all, urbansounds_avg, file = "data/urbansounds.RData")
