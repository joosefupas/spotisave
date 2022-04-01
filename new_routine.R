# routine to create .xlsx from a Spotify USER ID
# @joosefupas V1.0
library(spotifyr)
library(kableExtra)
library(tidyverse)
library(knitr)
library(lubridate)

remove(list=ls())

# connect with your account to API
client_id ="a5c60a5cdc364ba5aa03c662d5ae1543"
client_secret = "dc7d5d3bbee54c92961957e7120d351b"
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)
access_token <- get_spotify_access_token()

# select user ID (retrieved from spotify)
# user_id = "azaadeh"
user_id = c("oftanicola","lidiaberloco","azaadeh")

for (user_id in user_id) {
  
  
  # get user playlists
  my_plays = get_user_playlists(user_id = user_id,limit = 50,offset = 0)
  my_plays = rbind(my_plays,get_user_playlists(user_id = user_id,limit = 50,offset = 51))
  
  
  
  # eliminate podcasts ------------------------------------------------------
  for (i in my_plays$name){
    if (grepl("podcas|Podcast|PODCAS",i)){
      to_eliminate = i
      print(paste("DETECTED: ",to_eliminate,sep=" "))
      my_plays = my_plays[!grepl(i,my_plays$name),]
    }
  }
  
  
  # grab owner display name: what's the logic? take the name of the most frequent name (which, 
  # presumably, will be the user name!)
  
  owner.display_name_var = attributes(sort(table(my_plays$owner.display_name),decreasing = T)[1])[[1]]
  owner.id_var = attributes(sort(table(my_plays$owner.id),decreasing = T)[1])[[1]]
  
  # grab max of n tracks as scalar
  max_n_tracks = my_plays %>% filter(owner.display_name==owner.display_name_var,  
                                     owner.id == owner.id_var )%>%
    summarise(max(tracks.total)) %>% pull()
  
  
  # filter to only author's playlists!
  id_vectr= my_plays %>% dplyr::filter(owner.display_name==owner.display_name_var) %>% dplyr::filter(owner.id == owner.id) %>%
    select(id) %>% pull
  length(id_vectr) != 0
  length(id_vectr)
  
  
  # new part, gotta pick up the playlists! ----------------------------------
  # check the name of playlists from id_vectr

  play_placehold = left_join(data.frame(id = id_vectr),
                             my_plays %>% select(owner.display_name,id,name,tracks.total))



  
  # create with a loop the overall playlist track data frame
  pr = data.frame()
  pr_temp = data.frame()
  
  
  if (user_id =="azaadeh" || user_id =="lidiaberloco" ){
    
    authorization = access_token
    playlist_tracks <- map_df(id_vectr, function(playlist_uri) {
      this_playlist <- get_playlist(playlist_uri, authorization = authorization)
      n_tracks <- this_playlist$tracks$total
      num_loops <- ceiling(n_tracks/100)
      map_df(1:num_loops, function(this_loop) {
        
        
        
        get_playlist_tracks(this_playlist$id, limit = 100, 
                            offset = (this_loop - 1) * 100, authorization = authorization) %>% 
          mutate(playlist_id = this_playlist$id, playlist_name = this_playlist$name, 
                 playlist_img = NA,  # @
                 playlist_owner_name = this_playlist$owner$display_name, 
                 playlist_owner_id = this_playlist$owner$id)
      })
    })
    
    
    dupe_columns <- c("duration_ms", "type", "uri", "track_href")
    num_loops_tracks <- ceiling(nrow(playlist_tracks)/100)
    track_audio_features <- map_df(1:num_loops_tracks, function(this_loop) {
      track_ids <- playlist_tracks %>% slice(((this_loop * 
                                                 100) - 99):(this_loop * 100)) %>% pull(track.id)
      get_track_audio_features(track_ids, authorization = authorization)
    }) %>% select(-dupe_columns) %>% rename(track.id = id)
    
    # join
    # pr = cbind(playlist_tracks,track_audio_features)
    track_audio_features$track.id = NULL
    pr = cbind(playlist_tracks,track_audio_features)
    # sort(names(pr))
    if (file.exists(paste(user_id,"sum.txt",sep="_"))) {
      print(paste("HOUSTON WE HAVE A PROBLEM FILE WAS ALREADY PRESENT: I'LL DELETE IT NO WORRIES"))
      unlink(x = paste(user_id,"sum.txt",sep="_"), recursive = FALSE, force = FALSE)     
    }
    
    
    counter = 0
    for (i in 1:length(lengths(pr$track.artists))){
      write(capture.output(cat(pr$track.artists[[i]][[3]],sep="+")),file=paste(user_id,"sum.txt",sep="_"),append=T)
      counter = counter+1
      print(counter)
    }
    
    # create vect_art_names
    vect_art_names = readLines(paste(user_id,"sum.txt",sep="_"),warn=F)
    vect_art_names = data.frame(vect_art_names)
    names(vect_art_names) = "track_author"
    
    # checks
    pr = cbind(vect_art_names,pr)
    pr =   pr %>% dplyr::select(playlist_name,playlist_owner_id, track.name,track_author,everything())
    
    
    
  } else {
  
  
  
  # loop rbind
  counter=0
  for (i in id_vectr){
      pr_temp = get_playlist_audio_features(user_id,i)
      pr = rbind(pr,pr_temp)
      print(paste("Working on Playlist n:", counter))
      counter = counter+1
      if (print(sum(duplicated(pr$track.name)) == 0)) {
        print("OK LET'S GO NO DUPLICATED")
      }
    
  }
  
  }
  
  # remove lists before saving
  cols = pr %>% select_if(is.list) %>% colnames()
  cols
  pr = select(pr, -one_of(cols)) 
  
  
  
  
 
  # save oftanicola
  # library(xlsx)
  getwd()
  write.table(pr,file = paste("C:/Users/joose/Desktop/spotify/",user_id,"_",
                              format(Sys.time(), "%Y-%m-%d_%Z_%H-%M-%S"),
                              "_",".csv",sep=""),row.names = F,sep=",")
  
  
  
}
