//------------------------------------------------------------------------------
#include "Object.h"
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <iostream>
//------------------------------------------------------------------------------
#define MAX_NAME_LENGTH 1024
//------------------------------------------------------------------------------
//                         FILE PRIVATE DECLARATIONS
//------------------------------------------------------------------------------
static void readLine(std::string& line, std::ifstream& file);
static void processLine(
    Obj::File& file, 
    unsigned int lineNo, 
    std::string& line
);
static void processMatLine(
    Obj::File& file, 
    unsigned int lineNo, 
    std::string& line
);
static bool addObject(Obj::File& file, std::string& line);
static bool addGroup(Obj::File& file, std::string& line);
static bool addPosition(Obj::File& file, std::string& line);
static bool addNormal(Obj::File& file, std::string& line);
static bool addTexCoord(Obj::File& file, std::string& line);
static bool addFace(Obj::File& file, std::string& line);
static bool setCurrentMaterial(Obj::File& file, std::string& line);
static bool readMaterialFile(Obj::File& file, std::string& line);
static void reportError(
    const std::string& filename,
    unsigned int lineNumber, 
    const std::string& line
);

static void (*errorHandler_)(
    const std::string& filename,
    unsigned int lineNumber, 
    const std::string& line
) = NULL;
static std::string filename_;
static std::string filenameMat_;
static unsigned int matIndex_;

//------------------------------------------------------------------------------
//                           PUBLIC DEFINITIONS
//------------------------------------------------------------------------------
Obj::File* Obj::Load(
    const std::string& filename
)
{
    std::ifstream file;
    std::string line;
    filename_ = filename;

    file.open(filename.c_str());

    // check if files could be opened
    if (!file.is_open())
    {
        return NULL;
    }

    // create an .obj file struct to store the files contents
    Obj::File* objFile = new Obj::File();

    // save the name of the file
    objFile->Name = filename;

    // set the first entries of the positions, tex coords and normals to NULL
    objFile->Positions.push_back(Math::Vector3F(0.0f, 0.0f, 0.0f));
    objFile->TexCoords.push_back(Math::Vector2F(0.0f, 0.0f));
    objFile->Normals.push_back(Math::Vector3F(0.0f, 0.0f, 0.0f));

    // set the first material to be a default material
    objFile->Materials.push_back(Material());

    // set the current material index to 0 (the default index)
    matIndex_ = 0;

    // fill the struct
    unsigned int lineNo = 1;
    while(file.good())
    {
        readLine(line, file);
        processLine(*objFile, lineNo, line);
        lineNo++;
    };

    file.close();

    return objFile;
}
//------------------------------------------------------------------------------
void Obj::Release(Obj::File** file)
{
    delete *file;
    *file = NULL;
}
//------------------------------------------------------------------------------
void Obj::SetErrorHander(
    void (*errorHandler)(
        const std::string& filename,
        unsigned int lineNumber, 
        const std::string& line
    )
)
{
    errorHandler_ = errorHandler;
}
//------------------------------------------------------------------------------
void Obj::Dump(const Obj::File* file)
{

    std::cout << "+-------------------------------------------------------------------" << std::endl;
    std::cout << "| Dumping: " << file->Name  << std::endl;
    std::cout << "+-------------------------------------------------------------------\n" << std::endl;

    std::cout << "Materials___________________________________________________________" << std::endl;

    for (unsigned int i = 0; i < file->Materials.size(); i++)
    {
        std::cout << file->Materials[i].ToString() << std::endl;
    }


    std::cout << "Objects______________________________________________________________" << std::endl;
    std::cout << "Number of Objects " << file->Objects.size() << std::endl;

    for (unsigned int i = 0; i < file->Objects.size(); i++)
    {
        std::cout << "\n\tObject " << i << std::endl;
        std::cout << "\tName: " << file->Objects[i].Name << std::endl;

        for (unsigned int j = 0;  j < file->Objects[i].Groups.size() ; j++)
        {
            std::cout << "\n\t\tGroup " << j << std::endl;
            std::cout << "\t\tName: " << file->Objects[i].Groups[j].Name << std::endl;
            std::cout << "\t\tFaceCount: " << file->Objects[i].Groups[j].Faces.size() << std::endl;
            std::cout << "\n\t\tFaces:" << std::endl;

            unsigned int numFaces = file->Objects[i].Groups[j].Faces.size();

            for (unsigned int k = 0; k < numFaces; k++)
            {
                const Obj::Face& f = file->Objects[i].Groups[j].Faces[k];
                const Math::Tuple3UI& p = f.PositionIndices;
                const Math::Tuple3UI& t = f.TexCoordsIndices;
                const Math::Tuple3UI& n = f.NormalIndices;

                std::cout << "\t\t" 
                    << p[0] << "/" << t[0] << "/" << n[0] << " "
                    << p[1] << "/" << t[1] << "/" << n[1] << " "
                    << p[2] << "/" << t[2] << "/" << n[2] << " "
                    << "mat: " << f.MaterialIndex << " "
                    << std::endl;
            }
        }
    }

    std::cout << "\nPositions__________________________________________________________" << std::endl;
    std::cout << "\nPositionCount " << file->Positions.size() << std::endl;
;

    for (unsigned int i = 0; i < file->Positions.size(); i++)
    {
        const Math::Vector3F& pos = file->Positions[i];
        std::cout << "\t" << pos.ToString() << std::endl;
    }

    std::cout << "\nTexCoords__________________________________________________________" << std::endl;
    std::cout << "\nTexCoordCount " << file->TexCoords.size() << std::endl;
    

    for (unsigned int i = 0; i < file->TexCoords.size(); i++)
    {
        const Math::Vector2F& tc = file->TexCoords[i];
        std::cout << "\t" << tc.ToString() << std::endl;
    }

    std::cout << "\nNormals____________________________________________________________" << std::endl;    
    std::cout << "\nNormalCount " << file->Normals.size() << std::endl;


    for (unsigned int i = 0; i < file->Normals.size(); i++)
    {
        const Math::Vector3F& nrm = file->Normals[i];
        std::cout << "\t" << nrm.ToString() << std::endl;
    }
}
//------------------------------------------------------------------------------
//                       FILE PRIVATE DEFINITIONS
//------------------------------------------------------------------------------
void readLine(std::string& line, std::ifstream& file)
{
    std::getline(file, line);
}
//------------------------------------------------------------------------------
void processLine(Obj::File& file, unsigned int lineNo, std::string& line)
{
    #define CHECK_ERR(x) if (!x) {reportError(filename_, lineNo, line);}
    
    // TODO: maybe trim lines
    
    if (line.find("mtllib") == 0)
    {
        CHECK_ERR(readMaterialFile(file, line))
        return;
    }

    if (line.find("usemtl") == 0)
    {
        CHECK_ERR(setCurrentMaterial(file, line))
        return;
    }


    if (line.c_str()[0] == 'o')
    {
        CHECK_ERR(addObject(file, line))
        return;
    }

    if (line.c_str()[0] == 'g')
    {
        CHECK_ERR(addGroup(file, line))
        return;
    }

    if (line.c_str()[0] == 'v' && line.c_str()[1] == 'n')
    {
        CHECK_ERR(addNormal(file, line))
        return;
    }

    if (line.c_str()[0] == 'v' && line.c_str()[1] == 't')
    {
        CHECK_ERR(addTexCoord(file, line))
        return;
    }    

    if (line.c_str()[0] == 'v')
    {
        CHECK_ERR(addPosition(file, line))
        return;
    }

    if (line.c_str()[0] == 'f')
    {
        CHECK_ERR(addFace(file, line))
        return;
    }

}
//------------------------------------------------------------------------------
bool addPosition(Obj::File& file, std::string& line)
{
    Math::Vector3F pos;    
    int n = std::sscanf(line.c_str(), "v %f %f %f", &pos[0], &pos[1], &pos[2]);
    
    if (n != 3)
    {
        return false;
    }

    file.Positions.push_back(pos);

    return true;
}
//------------------------------------------------------------------------------
bool addNormal(Obj::File& file, std::string& line)
{
    Math::Vector3F nrm;
    int n = std::sscanf(line.c_str() , "vn %f %f %f", &nrm[0], &nrm[1], &nrm[2]);

    if (n != 3)
    {
        return false;
    }

    file.Normals.push_back(nrm);

    return true;
}
//------------------------------------------------------------------------------
bool addTexCoord(Obj::File& file, std::string& line)
{
    Math::Vector2F tc;
    int n = std::sscanf(line.c_str() , "vt %f %f", &tc[0], &tc[1]);

    if (n != 2)
    {
        return false;
    }

    file.TexCoords.push_back(tc);

    return true;   
}
//------------------------------------------------------------------------------
bool addFace(Obj::File& file, std::string& line)
{
    // check if an object struct already exists, if not create an "anonymous" 
    // one (i.e. one without a name)
    if (file.Objects.size() == 0)
    {
        Obj::Object o;
        o.Name = std::string("");
        file.Objects.push_back(o);
    }

    // if the current object has no groups add an anonymous group
    if (file.Objects[file.Objects.size() - 1].Groups.size() == 0)
    {
        Obj::Group g;
        g.Name = std::string("");
        file.Objects[file.Objects.size() - 1].Groups.push_back(g);
    }    

    // default init the face
    Obj::Face f;

    Math::Tuple3UI& posIds = f.PositionIndices;
    Math::Tuple3UI& tcIds = f.TexCoordsIndices;
    tcIds[0] = 0;
    tcIds[1] = 0;
    tcIds[2] = 0;
    Math::Tuple3UI& nrmIds = f.NormalIndices;
    nrmIds[0] = 0;
    nrmIds[1] = 0;
    nrmIds[2] = 0;

    f.MaterialIndex = matIndex_;

    // scan line
    unsigned int currObj = file.Objects.size() - 1;
    unsigned int currGrp = file.Objects[currObj].Groups.size() - 1;

    // case: f [p] [p] [p]
    int n = std::sscanf(
            line.c_str(), 
            "f %u %u %u", 
            &posIds[0], &posIds[1], &posIds[2]
        );

    if (n == 3)
    {
        file.Objects[currObj].Groups[currGrp].Faces.push_back(f);
        return true;
    }

    // case: f [p]/[tc] [p]/[tc] [p]/[tc]
    n = std::sscanf(
            line.c_str(), 
            "f %u/%u %u/%u %u/%u",
            &posIds[0], &tcIds[0], 
            &posIds[1], &tcIds[1], 
            &posIds[2], &tcIds[2]
        );

    if (n == 6)
    {
        file.Objects[currObj].Groups[currGrp].Faces.push_back(f);
        return true;
    }    

    // case: f [p]//[n] [p]//[n] [p]//[n]
    n = std::sscanf(
            line.c_str(), 
            "f %u//%u %u//%u %u//%u",
            &posIds[0], &nrmIds[0], 
            &posIds[1], &nrmIds[1], 
            &posIds[2], &nrmIds[2]
        );

    if (n == 6)
    {
        file.Objects[currObj].Groups[currGrp].Faces.push_back(f);
        return true;
    }  

    // case: f [p]/[tc]/[n] [p]/[tc]/[n] [p]/[tc]/[n]
    n = std::sscanf(
            line.c_str(), 
            "f %u/%u/%u %u/%u/%u %u/%u/%u",
            &posIds[0], &tcIds[0], &nrmIds[0], 
            &posIds[1], &tcIds[1], &nrmIds[1], 
            &posIds[2], &tcIds[2], &nrmIds[2]
        );

    if (n == 9)
    {
        file.Objects[currObj].Groups[currGrp].Faces.push_back(f);
        return true;
    }  


    return false;
}
//------------------------------------------------------------------------------
bool addObject(Obj::File& file, std::string& line)
{
    // ADDS AN OBJECT TO THE FILE STRUCTURE, RETURNS FALSE IF NO NAME COULD
    // BE FOUND
    char name[MAX_NAME_LENGTH];

    int n = std::sscanf(line.c_str(), "o %s", name);

    if (n != 1)
    {
        return false;
    }

    Obj::Object newObject;
    newObject.Name = name;
    file.Objects.push_back(newObject);

    return true;
}
//------------------------------------------------------------------------------
bool addGroup(Obj::File& file, std::string& line)
{
    char name[MAX_NAME_LENGTH];
    int n = std::sscanf(line.c_str(), "g %s", name);

    if (n != 1)
    {
        return false;
    }

    // if currently no object exists, add an anonymous one
    if (file.Objects.size() == 0)
    {
        Obj::Object o;
        o.Name = std::string("");
    }

    // add a group to the current object
    Obj::Group g;
    g.Name = std::string(name);

    file.Objects[file.Objects.size() - 1].Groups.push_back(g);

    return true;
}
//------------------------------------------------------------------------------
bool setCurrentMaterial(Obj::File& file, std::string& line)
{
    char matName[MAX_NAME_LENGTH];

    if (1 != std::sscanf(line.c_str(), "usemtl %s", matName))
    {
        return false;
    }
    
    // search for the material index that fits the name
    for (unsigned int i = 0; i < file.Materials.size(); i++)
    {
        if (0 == file.Materials[i].Name.compare(std::string(matName)))
        {
            matIndex_ = i;
            return true;
        }
    }

    matIndex_ = 0;

    return true;
}
//------------------------------------------------------------------------------
static bool readMaterialFile(Obj::File& file, std::string& line)
{
    // READS IN A LINE FROM A MATERIAL FILE

    char matFilename[MAX_NAME_LENGTH];
    int n = std::sscanf(line.c_str(), "mtllib %s", matFilename);

    if (n != 1)
    {
        return false;
    }

    filenameMat_ = matFilename;

    std::ifstream matFile;
    matFile.open(matFilename);

    if (!matFile.is_open())
    {
        std::cout << "could not open mat file with filename: " << matFilename << std::endl;
        return false;
    }

    std::string matLine;
    unsigned int lineNo = 1;

    while (matFile.good())
    {
        readLine(matLine, matFile);
        processMatLine(file, lineNo, matLine);
        lineNo++;
    }

    matFile.close();

    return true;
}
//------------------------------------------------------------------------------
void processMatLine(Obj::File& file, unsigned int lineNo, std::string& line)
{
    // READS IN ONE LINE [line] FROM AN [.mtl] FILE

    // TODO: trim string

    if (line.find("newmtl") == 0)
    {
        // push back an empty material to the [file]
        char matName[MAX_NAME_LENGTH];

        if (1 != std::sscanf(line.c_str(), "newmtl %s", matName))
        {
            reportError(filenameMat_, lineNo, line);
        }

        Obj::Material mat;
        mat.Name = std::string(matName);
        file.Materials.push_back(mat);
    }

    // fill the most recently add material
    unsigned int cmi = file.Materials.size() - 1;

    if (line.find("Ns") == 0)
    {
        float shininess;

        if (1 != std::sscanf(line.c_str(), "Ns %f", &shininess))
        {
            reportError(filenameMat_, lineNo, line);
            return;
        }

        file.Materials[cmi].Shininess = shininess;
    }

    if (line.find("Ni") == 0)
    {
        float refraction;

        if (1 != std::sscanf(line.c_str(), "Ni %f", &refraction))
        {
            reportError(filenameMat_, lineNo, line);
            return;
        }

        file.Materials[cmi].Refraction = refraction;
        return;
    }

    if (line.find("Ka") == 0)
    {
        Math::Vector3F ambient;

        int n = std::sscanf(
                line.c_str(), 
                "Ka %f %f %f",
                &ambient[0],
                &ambient[1],
                &ambient[2] 
            );

        if (3 != n)
        {
            reportError(filenameMat_, lineNo, line);
            return;
        }

        file.Materials[cmi].Ambient = ambient;
        return;
    }

    if (line.find("Kd") == 0)
    {
        Math::Vector3F diffuse;

        int n = std::sscanf(
                line.c_str(), 
                "Kd %f %f %f",
                &diffuse[0],
                &diffuse[1],
                &diffuse[2] 
            );

        if (3 != n)
        {
            reportError(filenameMat_, lineNo, line);
            return;
        }

        file.Materials[cmi].Diffuse = diffuse;
        return;
    }

    if (line.find("Ks") == 0)
    {
        Math::Vector3F specular;

        int n = std::sscanf(
                line.c_str(), 
                "Ks %f %f %f",
                &specular[0],
                &specular[1],
                &specular[2] 
            );

        if (3 != n)
        {
            reportError(filenameMat_, lineNo, line);
            return;
        }

        file.Materials[cmi].Specular = specular;
        return;
    }

    if (line.find("map_Ka") == 0)
    {
        char mapName[MAX_NAME_LENGTH];

        if (1 != std::sscanf(line.c_str(), "map_Ka %s", mapName))
        {
            reportError(filenameMat_, lineNo, line);
        }

        file.Materials[cmi].AmbientTexture = std::string(mapName);
        return;
    }

    if (line.find("map_Kd") == 0)
    {
        char mapName[MAX_NAME_LENGTH];

        if (1 != std::sscanf(line.c_str(), "map_Kd %s", mapName))
        {
            reportError(filenameMat_, lineNo, line);
        }

        file.Materials[cmi].DiffuseTexture = std::string(mapName);
        return;        
    }

    if (line.find("map_Ks") == 0)
    {
        char mapName[MAX_NAME_LENGTH];

        if (1 != std::sscanf(line.c_str(), "map_Ks %s", mapName))
        {
            reportError(filenameMat_, lineNo, line);
        }

        file.Materials[cmi].SpecularTexture = std::string(mapName);
        return;            
    }
}
//------------------------------------------------------------------------------
static void reportError(
    const std::string& filename,
    unsigned int lineNumber, 
    const std::string& line
)
{
    if (errorHandler_ != NULL)
    {
        (*errorHandler_)(filename, lineNumber, line);
    }
}
//------------------------------------------------------------------------------