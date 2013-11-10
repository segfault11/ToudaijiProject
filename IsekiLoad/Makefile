CC = g++
FLAGS = -Wall
LIBS = -lCGTK -lfreetype -lGLEW
FRAMEWORKS = -framework SDL2 -framework OpenGL
OBJ = IsakiRenderer.o
TARGET = IsekiLoad

$(TARGET) : Main.cpp $(OBJ)
	$(CC) -o $(TARGET) Main.cpp $(OBJ) $(FLAGS) $(LIBS) $(FRAMEWORKS)  

%.o: %.cpp
	$(CC) -c $< $(FLAGS)
