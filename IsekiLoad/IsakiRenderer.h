#ifndef ISAKIRENDERER_H__
#define ISAKIRENDERER_H__

#include <CGTK/Obj/Object.h> 
#include <CGTK/APP/IDrawable.h>

class IsakiRenderer : public APP::IDrawable
{
public:
    IsakiRenderer(const Obj::File& file);
    ~IsakiRenderer();

    void Draw();

private:
    class RealIsakiRenderer;
    RealIsakiRenderer* isakiRenderer;
};
 
#endif /* end of include guard: ISAKIRENDERER_H__ */