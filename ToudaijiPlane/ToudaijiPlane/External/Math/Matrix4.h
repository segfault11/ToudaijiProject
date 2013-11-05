/*!
** Description of a 4x4 Matrix
**    
** @since 2013-09-10
*/
#ifndef MATRIX4_H__
#define MATRIX4_H__
 
#include "Vector4.h"
#include "Vector3.h"
#include <string>

namespace Math
{
    /*!
    ** Declaration of a 4x4 Matrix. Note memory is layed out in ROW MAJOR 
    ** fashion.
    **    
    ** @since 2013-09-11 
    */
    template<typename T>
    class Matrix4
    {
    public:
        Matrix4() {};
        ~Matrix4() {};

        inline void Transpose();
        inline const Vector4<T>& operator[](unsigned int i) const;
        inline Vector4<T>& operator[](unsigned int i);

        /*!
        ** Gets the raw data in form of a linear array with 16 elements.
        */
        const T* GetData() const;

        /*!
        **  Turns the matrix to an OpenGL perspective matrix. NOTE THAT THE 
        **  MATRIX IS STILL ROW MAJOR AND NEEDS TO BE TRANSPOSED WHEN BEING 
        **  PASSED TO OPENGL.
        */
        inline void MakePerspective(
            const T& l, const T& r, 
            const T& b, const T& t, 
            const T& n, const T& f
        );

        /*!
        **  Turns the matrix to an OpenGL perspective matrix. NOTE THAT THE 
        **  MATRIX IS STILL ROW MAJOR AND NEEDS TO BE TRANSPOSED WHEN BEING 
        **  PASSED TO OPENGL.
        */
        inline void MakePerspective(
            const T& fovy, 
            const T& aspect, 
            const T& near,
            const T& far
        );

        /*!
        **  Turns the matrix to an OpenGL view matrix.NOTE THAT THE 
        **  MATRIX IS STILL ROW MAJOR AND NEEDS TO BE TRANSPOSED WHEN BEING 
        **  PASSED TO OPENGL.
        **
        **  @param eye The position of the camera.
        **  @param f The point the camera focuses on.
        **  @param up The orientation of the camera.
        */
        inline void MakeView(    
            const Math::Vector3<T>& eye, 
            const Math::Vector3<T>& f,
            const Math::Vector3<T>& up
        );

        /*!
        **  Turns the matrix to an OpenGL rotation matrix for the y axis. NOTE 
        **  THAT THE MATRIX IS STILL ROW MAJOR AND NEEDS TO BE TRANSPOSED WHEN 
        **  BEING PASSED TO OPENGL.
        */
        inline void MakeRotationY(const T& angle);

        /*!
        **  Turns the matrix to an OpenGL scale matrix. 
        **
        **  NOTE: 
        **  THAT THE MATRIX IS STILL ROW MAJOR AND NEEDS TO BE TRANSPOSED WHEN 
        **  BEING PASSED TO OPENGL.
        */
        inline void MakeScale(const T& sx, const T& sy, const T& sz);


        /*!
        ** Fills the matrix with zeroes.
        */        
        inline void MakeZero();

        /*!
        ** Turns the matrix to an identity matrix.
        */
        inline void MakeIdentity();

    private:    
        Vector4<Vector4<T> > data_;
    };

    #include "Matrix4.inl"

    typedef Matrix4<float> Matrix4F;
}
#endif /* end of include guard: MATRIX4_H__ */