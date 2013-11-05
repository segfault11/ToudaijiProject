/*!
** @file Vector2F.h
**    
** @since 2013-09-06 
*/
#ifndef VECTOR2_H__
#define VECTOR2_H__

#include "Tuple.h"

namespace Math
{
    template<typename T>
    class Vector2
    {
        public:
            Vector2() {}
            Vector2(const T& x, const T& y);
            ~Vector2() {};

            Vector2(const Vector2& orig);
            Vector2& operator=(const Vector2& orig);

            inline std::string ToString() const;

            inline operator const T*() const {return data_;}
            inline operator T*() {return data_;}

            inline const T& GetX() const {return data_[0];}
            inline const T& GetY() const {return data_[1];}
            inline const T& GetZ() const {return data_[2];}  
                      
        private:
            Tuple<2, T> data_;
    };


    #include "Vector2.inl" 
     
    typedef Vector2<float> Vector2F;
    typedef Vector2<int> Vector2I;
    typedef Vector2<unsigned int> Vector2UI;

}
 
#endif /* end of include guard: VECTOR2_H__ */