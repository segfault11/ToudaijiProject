/*!
** Vector3f.h
**    
** @since 2013-09-05 
*/
#ifndef VECTOR3_H__
#define VECTOR3_H__

#include <cmath>
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
    class Vector3
    {
    public:
        Vector3() {}
        Vector3(const T& x, const T& y, const T& z);
        ~Vector3() {};

        Vector3(const Vector3& orig);
        Vector3& operator=(const Vector3& orig);

        inline operator const T*() const {return data_;}
        inline operator T*() {return data_;}
        
        inline std::string ToString() const;

        // class access
        inline const T& operator[](unsigned int i) const;
        inline T& operator[](unsigned int i);

        inline const T& GetX() const {return data_[0];}
        inline const T& GetY() const {return data_[1];}
        inline const T& GetZ() const {return data_[2];}

        // vector operations
        inline Vector3<T> operator-(const Vector3<T>& v) const;
        inline Vector3<T> operator+(const Vector3<T>& v) const;
        inline Vector3<T> operator*(const T& a) const;
        inline Vector3<T>& operator+=(const Vector3<T>& v);
        inline Vector3<T> Cross(const Vector3<T>& v) const;
        inline T Dot(const Vector3<T>& v) const;

        inline void Normalize();

    private:
        Tuple<3, T> data_;
    };

    typedef Vector3<float> Vector3F;
    typedef Vector3<int> Vector3I;
    typedef Vector3<unsigned int> Vector3UI;

    void Cross(Vector3F& res, const Vector3F& a, const Vector3F& b);

    #include "Vector3.inl" 
}


#endif /* end of include guard: VECTOR3_H__ */