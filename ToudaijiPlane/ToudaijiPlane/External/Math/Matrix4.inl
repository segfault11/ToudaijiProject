//------------------------------------------------------------------------------
template<typename T>
Math::Vector4<T>& Math::Matrix4<T>::operator[](unsigned int i)
{
    CGTK_ASSERT(i < 4)
    return data_[i];
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::Transpose()
{
    unsigned int k = 1;
    for (unsigned int i = 0; i < 4; i++)
    {
        for (unsigned int j = k; j < 4; j++)
        {
            T ele = (*this)[i][j];
            (*this)[i][j] = (*this)[j][i];
            (*this)[j][i] = ele;
        }
        k++;
    }
}
//------------------------------------------------------------------------------
template<typename T>
const T* Math::Matrix4<T>::GetData() const
{
    return &data_[0][0];
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakePerspective(
    const T& fovy, 
    const T& aspect, 
    const T& near, 
    const T& far
)
{
    T t = tanf((fovy/2.0)*(3.141593f/180.0f));
    T h = near*t;
    T w = h*aspect;

    this->MakePerspective(-w, w, -h, h, near, far);
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakePerspective(
    const T& l, const T& r, 
    const T& b, const T& t, 
    const T& n, const T& f
)
{
    T* raw = static_cast<T*>(data_[0]);

    raw[0] = 2.0f*n/(r - l);
    raw[1] = 0.0f;
    raw[2] = 0.0f;
    raw[3] = 0.0f;

    raw[4] = 0.0f;
    raw[5] = 2.0f*n/(t - b);
    raw[6] = 0.0f;
    raw[7] = 0.0f;

    raw[8] = (r + l)/(r - l);
    raw[9] = (t + b)/(t - b);
    raw[10] = -(f + n)/(f - n);
    raw[11] = -1.0f;

    raw[12] = 0.0f;
    raw[13] = 0.0f;
    raw[14] = -2.0f*f*n/(f - n);
    raw[15] = 0.0f;     

    this->Transpose();
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakeView(    
    const Math::Vector3<T>& eye, 
    const Math::Vector3<T>& f,
    const Math::Vector3<T>& up
)
{
    
    Math::Vector3<T> n = eye - f;
    n.Normalize();
    
    Math::Vector3<T> u = up.Cross(n);
    u.Normalize();

    Math::Vector3<T> v = n.Cross(u);

    T* raw = static_cast<T*>(data_[0]);

    raw[0] = u[0];
    raw[4] = u[1];
    raw[8] = u[2];
    raw[12] = -u.Dot(eye);

    raw[1] = v[0];
    raw[5] = v[1];
    raw[9] = v[2];
    raw[13] = -v.Dot(eye);   

    raw[2] = n[0];
    raw[6] = n[1];
    raw[10] = n[2];
    raw[14] = -n.Dot(eye);   

    raw[3] = 0.0f;
    raw[7] = 0.0f;
    raw[11] = 0.0f;
    raw[15] = 1.0f;

    this->Transpose();
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakeIdentity()
{
    for (unsigned int i = 0; i < 4; i++)
    {
        for (unsigned int j = 0; j < 4; j++)
        {
            if (i == j)
            {
                data_[i][j] = static_cast<T>(1);
            }
            else
            {
                data_[i][j] = static_cast<T>(0);
            }
        }
    }
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakeScale(const T& sx, const T& sy, const T& sz)
{
    this->MakeZero();

    (*this)[0][0] = sx;
    (*this)[1][1] = sy;
    (*this)[2][2] = sz;
    (*this)[3][3] = static_cast<T>(1);
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakeZero()
{
    for (unsigned int i = 0; i < 4; i++)
    {
        for (unsigned int j = 0; j < 4; j++)
        {
            data_[i][j] = static_cast<T>(0);
        }
    }
}
//------------------------------------------------------------------------------
template<typename T>
void Math::Matrix4<T>::MakeRotationY(const T& angle)
{
    this->MakeZero();

    (*this)[0][0] = std::cos(angle);
    (*this)[0][2] = std::sin(angle);
    (*this)[1][1] = static_cast<T>(1);
    (*this)[2][0] = -std::sin(angle);
    (*this)[2][2] = std::cos(angle);    
    (*this)[3][3] = static_cast<T>(1);
}
//------------------------------------------------------------------------------