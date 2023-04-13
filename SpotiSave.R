# load libraries 
library(spotifyr)
library(dplyr)

# Spotify API credentials
Sys.setenv(SPOTIFY_CLIENT_ID = 'your_client_id_here')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'your_client_secret_here')
redirect_uri = "http://localhost/"

# put your(s) username(s) you want to save (if not yours/i.e. other users will save just the public playlists)
usernames = c("username1", "username2")


# Get an access token
access_token <- get_spotify_access_token()

for (username in usernames){
  
  # Get the user's playlists
  playlists <- list()
  offset <- 0
  limit <- 50
  
  while (TRUE) {
    new_playlists <- get_user_playlists(user_id = username, limit = limit, offset = offset)
    if (length(new_playlists$id) == 0) {
      break
    }
    playlists <- rbind(playlists, new_playlists)
    offset <- offset + limit
  }
  
  
  # Group by 'owner.display_name' and count the number of occurrences
  counts <- table(playlists$owner.display_name)
  
  # Get the most common value
  most_common <- names(counts)[which.max(counts)]
  
  # Filter the dataset by the most common value
  playlists <- playlists[playlists$owner.display_name == most_common, ]
  
  
  # Create a data frame to store the tracklists
  
  tracks = list()
  playlist_ids = playlists$id
  playlist_vector = c()
  
  # Loop through each playlist id and retrieve all tracks, with a maximum of 50 at a time
  for (playlist_id in playlist_ids){  
    offset = 0
    limit = 50
    total_tracks = playlists %>% filter(id==playlist_id) %>% pull(tracks.total)
    
    if (ncol(get_playlist_tracks(playlist_id=playlist_id)) ==42){
      while (offset <= total_tracks){
        tryCatch({
          new_tracks = get_playlist_tracks(playlist_id = playlist_id, offset = offset, limit = limit)
          offset = offset + limit
          tracks = rbind(tracks, new_tracks)
        }, error = function(e){ # Catch the error and display error message
          message(paste0("Error occurred: ", e$message))
        })
      }
      playlist_vector_temp = rep(playlist_id,total_tracks)
      playlist_vector = c(playlist_vector,playlist_vector_temp)  
    }
    
    
    
  }
  
  # Bind playlist id to each track
  tracks = cbind(tracks,playlist_vector)
  tracks = tracks %>% dplyr::rename(id = playlist_vector)
  
  # Remove any rows where the track id is missing
  tracks_temp = tracks
  
  # clean 
  for (i in 1:nrow(tracks_temp)) {
    if (is.na(tracks_temp[i, "track.id"])) {
      tracks_temp <- tracks_temp[-i,]
    }
  }
  
  # Retrieve the name(s) of each artist associated with each track
  artist_names = c()
  
  for (i in 1:length(tracks_temp$track.artists)){
    if (!is.null(tracks_temp$track.artists[[i]])){
      tryCatch({
        if (length(data.frame(tracks_temp$track.artists[i]) %>% pull(name)) == 1){
          temp_artist_name = data.frame(tracks_temp$track.artists[i]) %>% pull(name)
          artist_names = c(artist_names, temp_artist_name)
        } else {
          temp_artist_name = paste(tracks_temp$track.artists[[i]]$name, collapse = ", ")
          artist_names = c(artist_names, temp_artist_name)
        }
      },
      error = function(e) {
        print(paste("Error occurred for track artist", i, ":", e))
      })
    }
  }
  
  # Combine track and playlist data into one dataframe
  tracks_comp = left_join(tracks_temp,playlists %>% dplyr::select(id,name,owner.display_name))
  tracks_comp_fin = tracks_comp %>% dplyr::select(id,owner.display_name,name,track.id,track.name)
  tracks_comp_fin = cbind(tracks_comp_fin,artist_names) %>% dplyr::select(id,owner.display_name,name, artist_names, track.name,track.id) %>%  
    dplyr::rename(playlist_id = id, artist_name = artist_names, playlist_name=name)
  
  
  # Write data to CSV file
  write.csv(tracks_comp_fin, file = paste("track_data_",username,"_",Sys.Date(),".csv",sep=""), row.names = FALSE)
}



