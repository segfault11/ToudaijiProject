/*!
** Vector4f.h
**    
** @since 2013-09-05 
*/
#ifndef VECTOR4_H__
#define VECTOR4_H__

#include "Tuple.h"
#include "../Error/Error.h"

namespace Math
{
    /*!
    ** A three dimensional vector
    **    
    ** @since 2013-09-05 
    */
    template<typename T>
    class Vector4
    {
    public:
        Vector4() {}
        Vector4(const T& x, const T& y, const T& z);
        ~Vector4() {};

        Vector4(const Vector4& orig);
        Vector4& operator=(const Vector4& orig);

        inline operator const T*() const {return data_;}
        inline operator T*() {return data_;}
        
        inline std::string ToString() const;

        inline Vector4<T>& operator=(const T& a);

        // class access
        inline const T& operator[](unsigned int i) const;
        inline T& operator[](unsigned int i);

        inline const T& GetX() const {return data_[0];}
        inline const T& GetY() const {return data_[1];}
        inline const T& GetZ() const {return data_[2];}
        inline const T& GetW() const {return data_[3];}

    private:
        Tuple<4, T> data_;
    };

    #include "Vector4.inl" 
     
    typedef Vector4<float> Vector4F;
    typedef Vector4<int> Vector4I;
    typedef Vector4<unsigned int> Vector4UI;
}


#endif /* end of include guard: VECTOR3_H__ */