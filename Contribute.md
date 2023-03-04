# SpotiSave

SpotiSave is an R script that can be used to export Spotify playlists to CSV files. This script uses the Spotify Web API to fetch user's playlists and tracks. 

## Getting Started

### Prerequisites

- [R](https://www.r-project.org/)
- [spotifyr](https://github.com/charlie86/spotifyr) package

### Installation

1. Clone the repository to your local machine
git clone https://github.com/yourusername/spotisave.git
2. Install the required packages
```r
install.packages("spotifyr")
```

## Usage
Enter your Spotify API credentials in the script (SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET).
Run the script in RStudio or via the command line.
### Copy code
```r
source("spotisave.R")
```

### Output
The script will create a CSV file for each user's playlists in the format track_data_username.csv.

## Contributing
We welcome contributions from everyone. Before getting started, please read our contribution guidelines.

## License
This project is licensed under the MIT License.

