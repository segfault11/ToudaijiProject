#include <iostream>
#include <CGTK/Obj/Object.h>
#include <CGTK/APP/Application.h>
#include "IsakiRenderer.h"


int main(int argc, char const *argv[])
{
    APP::Init("IsekiLoad", 0, 0, 1000, 800);
    
    APP::Camera cam(        
            Math::Vector3F(0.2f, 0.2f, 0.2f), 
            Math::Vector3F(0.0f, 0.0f, 0.0f),
            Math::Vector3F(0.0f, 1.0f, 0.0f),
            60.0f, 1000.0f/800.0f, 0.01f, 100.0f
        );
    APP::SetCamera(cam);

    const Obj::File* file = Obj::Load("Iseki2.obj");
    // Obj::Dump(file);

    IsakiRenderer geo(*file);
    APP::RegisterDrawable(geo);
    APP::Run();
    APP::Destroy();

    return 0;
}