#include "../Error/Error.h"

template<typename T>
Vector3<T>::Vector3(const T& x, const T& y, const T& z)
{
    data_[0] = x;
    data_[1] = y;
    data_[2] = z;
}

template<typename T>
Vector3<T>::Vector3(const Vector3& orig)
{
    data_ = orig.data_;
}

template<typename T>
Vector3<T>& Vector3<T>::operator=(const Vector3& orig)
{
    data_ = orig.data_;
    return *this;
}

template<typename T>
T& Vector3<T>::operator[](unsigned int i)
{
    CGTK_ASSERT(i < 3)

    return data_[i];
}

template<typename T>
const T& Vector3<T>::operator[](unsigned int i) const
{
    CGTK_ASSERT(i < 3)
    
    return data_[i];
}

template<typename T>
std::string Vector3<T>::ToString() const
{
    std::stringstream s;
    s << "[x = " << data_[0] << " y = " << data_[1] << " z = " << data_[2] << "]";
    return s.str();
}

template<typename T>
void Vector3<T>::Normalize()
{
    T norm = sqrt(data_[0]*data_[0] + data_[1]*data_[1] + data_[2]*data_[2]);

    CGTK_ASSERT(norm != 0.0)

    data_[0] /= norm;
    data_[1] /= norm;
    data_[2] /= norm;
}

template<typename T>
Vector3<T> Vector3<T>::operator-(const Vector3<T>& v) const
{
    Vector3<T> result;

    result[0] = (*this)[0] - v[0];
    result[1] = (*this)[1] - v[1];
    result[2] = (*this)[2] - v[2];

    return result;
}

template<typename T>
Vector3<T> Vector3<T>::operator+(const Vector3<T>& v) const
{
    Vector3<T> result;

    result[0] = (*this)[0] + v[0];
    result[1] = (*this)[1] + v[1];
    result[2] = (*this)[2] + v[2];

    return result;
}

template<typename T>
Vector3<T>& Vector3<T>::operator+=(const Vector3<T>& v)
{
    (*this)[0] += v[0];
    (*this)[1] += v[1];
    (*this)[2] += v[2];

    return *this;
}

template<typename T>
Vector3<T> Vector3<T>::Cross(const Vector3<T>& v) const
{
    Vector3<T> result;

    result[0] = (*this)[1]*v[2] - (*this)[2]*v[1];
    result[1] = -((*this)[0]*v[2] - (*this)[2]*v[0]);
    result[2] = (*this)[0]*v[1] - (*this)[1]*v[0]; 
    
    return result;
}

template<typename T>
T Vector3<T>::Dot(const Vector3<T>& v) const
{
    return (*this)[0]*v[0] + (*this)[1]*v[1] + (*this)[2]*v[2];
}

template<typename T>
Vector3<T> Vector3<T>::operator*(const T& a) const
{
    Vector3<T> result;
    
    result[0] = (*this)[0]*a;
    result[1] = (*this)[1]*a;
    result[2] = (*this)[2]*a;

    return result;
} 
