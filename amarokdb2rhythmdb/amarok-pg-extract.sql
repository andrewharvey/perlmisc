--invoke using `psql -d amarokdb -f amarok-pg-extract.sql -o extract.csv`
COPY (
  SELECT
    tags.title as title,
    genre.name as genre,
    artist.name as artist,
    album.name as album,
    tags.track as track_number,
    tags.discnumber as disc_number,
    tags.length as duration,
    tags.filesize as file_size,
    tags.url as location,
    -- mount-point
    tags.modifydate as mtime,
    tags.createdate as first_seen,
    statistics.accessdate as last_seen,
    statistics.rating as rating,
    statistics.playcounter as play_count,
    --last-played
    tags.bitrate as bitrate,
    --date
    --mimetype. can't extract will need to fill in from file extension/magic numeber
    year.name as year
    --keyword
    --comment
    --bpm
    
    -- how to export:?
    --composer
    ---labels
    --lyrics
    
  FROM 
    tags
    INNER JOIN artist on tags.artist = artist.id
    INNER JOIN album on tags.album = album.id
    INNER JOIN composer on tags.composer = composer.id
    INNER JOIN genre on tags.genre = genre.id
    INNER JOIN year on tags.year = year.id
    INNER JOIN statistics on tags.url = statistics.url
  --LIMIT 2;
) TO STDOUT WITH CSV HEADER;
