# Spotify Playlist Analyzer
This R script retrieves all the tracks from a user's Spotify playlists, filters them to the playlists with the most tracks, and outputs a CSV file with the playlist name, track name, and artist name for each track in those playlists.

## Installation
Install R on your computer (https://www.r-project.org/).
Install the spotifyr package by running the following command in R: install.packages("spotifyr").
## Usage
Sign up for a Spotify Developer account and create a new app to obtain a client ID and secret key (https://developer.spotify.com/dashboard/applications).
In the R script, replace the SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET values with your app's client ID and secret key.
Replace the usernames vector with the Spotify usernames whose playlists you want to analyze.
Run the script in R.
The script will create a CSV file for each user in the same directory as the script. The file names will be in the format track_data_USERNAME.csv.

## License
This project is licensed under the MIT License.
