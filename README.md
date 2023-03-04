# SpotiSave

SpotiSave is an R script that can be used to export Spotify playlists to CSV files. This script uses the Spotify Web API to fetch user's playlists and tracks. 

## Getting Started

### Prerequisites
Install R, spotifyr and dplyr libraries
- [R](https://www.r-project.org/)
- [spotifyr](https://github.com/charlie86/spotifyr) package
- [dplyr](https://www.r-project.org/nosvn/pandoc/dplyr.html) package

### Installation

1. Clone the repository to your local machine
git clone https://github.com/joosefupas/spotisave.git
2. Install the required packages
```r
install.packages("spotifyr")
install.packages("dplyr")

```

## Usage
1. Sign up for a Spotify Developer account and create a new app to obtain a client ID and secret key (https://developer.spotify.com/dashboard/applications) or (https://www.rcharlie.com/spotifyr/) for another introductory tutorial in ```spotifyr``` context.
2. In the R script, replace the SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET values with your app's client ID and secret key.
3. Replace the usernames vector with the Spotify usernames whose playlists you want to analyze.
4. Run the script in R.

The script will create a CSV file for each user in the same directory as the script. The file names will be in the format track_data_USERNAME.csv.

### Copy code
```r
source("spotisave.R")
```

### Output
The script will create a CSV file for each user's playlists in the format track_data_username.csv.

## Contributing
We welcome contributions from everyone.

## License
This project is licensed under the MIT License.

