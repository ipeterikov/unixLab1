#!/bin/bash -e

deleteTempD() {
  echo "temp directory deleted"
  # delete temp directory
  rm -rf "$temp_dir"
  exit 1
}

trap deleteTempD EXIT INT TERM

if [ $# -ne 1 ]; then
  echo "Usage: $0 <source_file>"
  exit 1
fi

source_file="$1"

if [ ! -f "$source_file" ]; then
  echo "Source file not found: $source_file"
  exit 1
fi

# Create a temp directory
temp_dir=$(mktemp -d)
if [ ! -d "$temp_dir" ]; then
  echo "Failed to create a temp directory."
  deleteTempD
fi

# Find the output file name in the "&Output:" comment
output_name=$(grep '&Output:' "$source_file" | awk '{print $2}')

if [ -z "$output_name" ]; then
  echo "No '&Output:' comment found in the source file."
  deleteTempD
fi

# Compile the source file, place output in the tempdir.
cp "$source_file" "$temp_dir"/
directory=$(pwd)
cd "$temp_dir"
case "$source_file" in
	*.c)
	  gcc "$source_file" -o "$temp_dir/$output_name"
	  ;;
	*.cpp)
	  g++ "$source_file" -o "$temp_dir/$output_name"
	  ;;
	*)
	  echo "Unsupported file type! "
	  exit 3
esac
if [ ! -f "$output_name" ]; then
  echo "build not successful"
  exit 1
else 
cd "$directory"
mv "$temp_dir/$output_name" "./$output_name"
echo "Build successful: &Output: $output_name"
fi
rm -rf "$temp_dir"
