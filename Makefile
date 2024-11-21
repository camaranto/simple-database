# Compiler and flags
CC = gcc
CFLAGS = -Wall -Werror -g

OUTPUT_DIR = bin
SRC = src/main.c

# Target executable
TARGET = $(OUTPUT_DIR)/SimpleDB

# Build the target
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)
# Clean up build files
clean:
	rm -f $(TARGET)
# execute the build binary
run:
	./$(TARGET)
rebuild: clean $(TARGET)

test:
	rspec tests/test.rb
