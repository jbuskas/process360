library(DBI)
library(RSQLite)

# Create or connect to the database
db_path <- "data//image_database.sqlite"
con <- dbConnect(RSQLite::SQLite(), db_path)

# Create table
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS images (
    id INTEGER PRIMARY KEY,
    site TEXT,
    original_image TEXT,
    hemi_image TEXT,
    forest_floor_images TEXT,
    understory_images TEXT
  )
")

# Clear existing data
dbExecute(con, "DELETE FROM images")

# Insert sample data
dbExecute(con, "
  INSERT INTO images (site, original_image, hemi_image, forest_floor_images, understory_images)
  VALUES (
    'Site1',
    'testSite1\\IMG_20250526_102917_00_205.jpg',
    'testSite1\\IMG_20250526_102917_00_205_hemi.jpg',
    'testSite1\\IMG_20250526_102917_00_205_top_left_zoomed.jpg,testSite1\\IMG_20250526_102917_00_205_top_right_zoomed.jpg,testSite1\\IMG_20250526_102917_00_205_bottom_left_zoomed.jpg,testSite1\\IMG_20250526_102917_00_205_bottom_right_zoomed.jpg',
    'testSite1\\IMG_20250526_102917_00_205_east_understory2.jpg,testSite1\\IMG_20250526_102917_00_205_north_understory2.jpg,testSite1\\IMG_20250526_102917_00_205_south_understory2.jpg,testSite1\\IMG_20250526_102917_00_205_west_understory2.jpg'
  )
")

dbDisconnect(con)
