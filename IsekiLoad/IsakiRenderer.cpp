//------------------------------------------------------------------------------
#include "IsakiRenderer.h"
#include <GL/glew.h>
#include <vector> 
#include <CGTK/Math/Vector3.h>
#include <CGTK/Util.h>
#include <CGTK/GLUE/Program.h>
#include <CGTK/GLUE/Texture.h>
#include <CGTK/APP/Application.h>
//------------------------------------------------------------------------------ // [MaterialGroup]'s DEFINITION       
class MaterialGroup
{
    // THE MATERIAL GROUP GROUPS GEOMETRY THAT HAS THE SAME MATERIAL.
public:
    MaterialGroup();
    ~MaterialGroup();

    void AddFace(const Obj::Face& face, const Obj::File& file);
    void SetMaterial(const Obj::Material& material);
    void Upload();
    void Draw();

private:
    std::vector<Math::Vector3F> positions;
    std::vector<Math::Vector3F> normals;
    std::vector<Math::Vector2F> texCoords;

    GLuint posBuffer;
    GLuint nrmBuffer;
    GLuint tcBuffer;
    GLuint vertexArray;

    Obj::Material material;

    GLuint diffuseTex;
};
//------------------------------------------------------------------------------
MaterialGroup::MaterialGroup() 
: 
    posBuffer(0), 
    nrmBuffer(0), 
    tcBuffer(0),
    vertexArray(0), 
    diffuseTex(0)
{

}
//------------------------------------------------------------------------------
MaterialGroup::~MaterialGroup() 
{
    if (this->posBuffer != 0)
    {
        glDeleteBuffers(1, &this->posBuffer);
    }

    if (this->nrmBuffer != 0)
    {
        glDeleteBuffers(1, &this->nrmBuffer);
    }

    if (this->tcBuffer != 0)
    {
        glDeleteBuffers(1, &this->tcBuffer);
    }

    if (this->vertexArray != 0)
    {
        glDeleteVertexArrays(1, &this->vertexArray);
    }

    if (this->diffuseTex != 0)
    {
        glDeleteTextures(1, &this->diffuseTex);
    }

}
//------------------------------------------------------------------------------
void MaterialGroup::SetMaterial(const Obj::Material& material)
{
    this->material = material;
}
//------------------------------------------------------------------------------
void MaterialGroup::AddFace(const Obj::Face& face, const Obj::File& file)
{  
    for (unsigned int i = 0; i < 3; i++)
    {
        this->positions.push_back(file.Positions[face.PositionIndices[i]]);
        this->normals.push_back(file.Normals[face.NormalIndices[i]]);
        this->texCoords.push_back(file.TexCoords[face.TexCoordsIndices[i]]);
    }
}
//------------------------------------------------------------------------------
void MaterialGroup::Upload()
{
    if (!this->vertexArray)
    {
        glGenBuffers(1, &this->posBuffer);
        CGTK_ASSERT(this->posBuffer != 0)

        glGenBuffers(1, &this->nrmBuffer);
        CGTK_ASSERT(this->nrmBuffer)

        glGenBuffers(1, &this->tcBuffer);
        CGTK_ASSERT(this->tcBuffer);   

        glGenVertexArrays(1, &this->vertexArray);
        CGTK_ASSERT(this->vertexArray)
        glBindVertexArray(this->vertexArray);

        glBindBuffer(GL_ARRAY_BUFFER, this->posBuffer);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);

        glBindBuffer(GL_ARRAY_BUFFER, this->nrmBuffer);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);

        glBindBuffer(GL_ARRAY_BUFFER, this->tcBuffer);
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, 0);

        CGTK_ASSERT(GL_NO_ERROR == glGetError())
    }

    // set buffer data
    glBindBuffer(GL_ARRAY_BUFFER, this->posBuffer);
    
    glBufferData(
        GL_ARRAY_BUFFER, 
        this->positions.size()*sizeof(Math::Vector3F), 
        this->positions.data(), 
        GL_STATIC_DRAW
    );

    glBindBuffer(GL_ARRAY_BUFFER, this->nrmBuffer);

    glBufferData(
        GL_ARRAY_BUFFER,
        this->normals.size()*sizeof(Math::Vector3F),
        this->normals.data(),
        GL_STATIC_DRAW
    );

    glBindBuffer(GL_ARRAY_BUFFER, this->tcBuffer);

    glBufferData(
        GL_ARRAY_BUFFER,
        this->texCoords.size()*sizeof(Math::Vector2F),
        this->texCoords.data(),
        GL_STATIC_DRAW
    );

    if (this->material.DiffuseTexture.size() > 0)
    {
        this->diffuseTex = GLUE::Texture2DCreateFromFile(
                this->material.DiffuseTexture.c_str()
            );
    }
}
//------------------------------------------------------------------------------
void MaterialGroup::Draw()
{
    glBindVertexArray(this->vertexArray);
    
    if (this->diffuseTex != 0)
    {
        glActiveTexture(0);
        glBindTexture(GL_TEXTURE_2D, this->diffuseTex);
    }
    
    glDrawArrays(GL_TRIANGLES, 0, this->positions.size());
    
}
//------------------------------------------------------------------------------ // [RealIsakiRenderer]'s IMPLEMENTATION 
class IsakiRenderer::RealIsakiRenderer
{
public:
    RealIsakiRenderer(const Obj::File& file);
    ~RealIsakiRenderer();

    void Draw();

private:
    std::vector<MaterialGroup> materialGroups;
    static GLuint program;
    static unsigned int programRefCount;
};
//------------------------------------------------------------------------------
GLuint IsakiRenderer::RealIsakiRenderer::program = 0;
unsigned int IsakiRenderer::RealIsakiRenderer::programRefCount = 0;
//------------------------------------------------------------------------------
IsakiRenderer::RealIsakiRenderer::RealIsakiRenderer(const Obj::File& file)
: materialGroups(file.Materials.size())
{
    // prepare geometry
    unsigned int numObjects = file.Objects.size();

    for (unsigned int i = 0; i < numObjects; i++)
    {
        unsigned int numGroups = file.Objects[i].Groups.size();

        for (unsigned int j = 0; j < numGroups; j++)
        {
            unsigned int numFaces = file.Objects[i].Groups[j].Faces.size();

            for (unsigned int k = 0; k < numFaces; k++)
            {
                const Obj::Face& face = file.Objects[i].Groups[j].Faces[k];
                unsigned int matIdx  = face.MaterialIndex;
                
                this->materialGroups[matIdx].AddFace(face, file);
            }
        }
    }

    // send material groups to graficscard
    for (unsigned int i = 0; i < this->materialGroups.size(); i++)
    {
        this->materialGroups[i].SetMaterial(file.Materials[i]);
        this->materialGroups[i].Upload();
    }

    // create program
    if (programRefCount == 0)
    {
        this->program = glCreateProgram();

        GLUE::ProgramAttachShaderFromFile(
            this->program, 
            GL_VERTEX_SHADER, 
            "GeometryVS.glsl"
        );

        GLUE::ProgramAttachShaderFromFile(
            this->program, 
            GL_FRAGMENT_SHADER, 
            "GeometryFS.glsl"
        );

        glBindAttribLocation(this->program, 0, "Position");
        glBindAttribLocation(this->program, 1, "Normal");
        glBindAttribLocation(this->program, 2, "TexCoord");
        glBindFragDataLocation(this->program, 0, "FragOut");
        GLUE::ProgramLink(this->program);

        CGTK_ASSERT(GL_NO_ERROR == glGetError());
    }

    programRefCount++;
}
//------------------------------------------------------------------------------
IsakiRenderer::RealIsakiRenderer::~RealIsakiRenderer()
{
    programRefCount--;

    if (programRefCount == 0)
    {
        glDeleteProgram(program);
    }
}
//------------------------------------------------------------------------------
void IsakiRenderer::RealIsakiRenderer::Draw()
{
    glUseProgram(this->program);
    
    Math::Matrix4F view;
    view.MakeIdentity();
    
    view.MakeView(
        Math::Vector3F(0.6f, 0.6f, 0.6f), 
        Math::Vector3F(0.0f, 0.0f, 0.0f), 
        Math::Vector3F(0.0f, 1.0f, 0.0f)
    );
    
    GLUE::ProgramUniformMatrix4F(
        this->program, 
        "View", 
        view.GetData(), 
        GL_TRUE
    );

    Math::Matrix4F proj;
    proj.MakePerspective(60.0f, 1000.0f/800.0f, 0.01f, 100.0f);
    GLUE::ProgramUniformMatrix4F(
        this->program, 
        "Proj", 
        proj.GetData(), 
        GL_TRUE
    );

    Math::Matrix4F model;
    static float angle = 0.0f;
    angle += 0.01f;
    model.MakeRotationY(angle);
    model.MakeIdentity();
    model.MakeScale(0.5f, 0.5f, 0.5f);


    GLUE::ProgramUniformMatrix4F(
        this->program, 
        "Model",
        model.GetData(), 
        GL_TRUE
    );

    for (unsigned int i = 0; i < this->materialGroups.size(); i++)
    {
        this->materialGroups[i].Draw();
    } 
}
//------------------------------------------------------------------------------ // [IsakiRenderer]'s IMPLEMENTATION 
IsakiRenderer::IsakiRenderer(const Obj::File& file)
{
    this->isakiRenderer = new RealIsakiRenderer(file);
}
//------------------------------------------------------------------------------
IsakiRenderer::~IsakiRenderer()
{
    delete this->isakiRenderer;
}
//------------------------------------------------------------------------------
void IsakiRenderer::Draw()
{
    this->isakiRenderer->Draw();
}
//------------------------------------------------------------------------------ // END OF FILE
