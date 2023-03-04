library(spotifyr)
library(dplyr)
remove(list=ls())

# Spotify API credentials
Sys.setenv(SPOTIFY_CLIENT_ID = 'your_client_id_here')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'your_client_secret_here')
redirect_uri = "http://localhost/"

# put your(s) username(s) you want to save (if not yours/i.e. other users will save just the public playlists)
usernames = c("username1", "username2")

# Get an access token
access_token <- get_spotify_access_token()

# Loop through each user's playlists and get the track data
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

  # Create a data frame to store the tracklists
  track_data <- data.frame(Playlist = character(),
                           Playlist_ID = character(),
                           Track_ID = character(),
                           Track_Name = character(),
                           Artist_Name = character(),
                           stringsAsFactors = FALSE)

  if (length(playlists$id) > 0) {
    for (i in 1:length(playlists$id)) {
      tracks <- get_playlist_tracks(playlists$id[i])
      if (length(tracks$track.id) > 0) {
        for (j in 1:length(tracks$track.id)) {
          track_data <- rbind(track_data, data.frame(Playlist = playlists$name[[i]],
                                                     Playlist_ID = playlists$id[[i]],
                                                     Owner = playlists$owner.display_name[[i]],
                                                     Track_ID = tracks$track.id[[j]],
                                                     Track_Name = tracks$track.name[[j]],
                                                     Artist_Name = tracks$track.artists[[j]]$name,
                                                     stringsAsFactors = FALSE))
        }
      }
    }
  }

  # Filter the data to only include tracks from the most common playlist owner
  top_display_name <- track_data %>%
    dplyr::group_by(Owner) %>%
    summarize(count = n()) %>%
    top_n(1, count) %>%
    pull(Owner)

  filtered_track_data <- track_data %>%
    filter(Owner %in% top_display_name) %>%
    group_by(Playlist_ID, Track_ID) %>%
    summarize(Playlist = first(Playlist),
              Track_Name = first(Track_Name),
              Artist_Name = paste(Artist_Name, collapse = ",")) %>%
    ungroup()

  # Write the data to a CSV file
  write.csv(filtered_track_data, file = paste("track_data_",username,".csv",sep=""), row.names = FALSE)
}
