#ifndef UTIL_H__
#define UTIL_H__

/*
** Declares default constructor, copy constructor and = operator for a class.
*/
#define DECL_DEFAULTS(x) x(); x(const x&); x& operator=(const x&);

/*
** Delete pointer only if it is not null. 
*/
#define DELETE(x) if (x != NULL) {delete x; x = NULL;}
#define CGTK_DELETE(x) if (x != NULL) {delete x; x = NULL;} // todo: remove 

/*
** Delete pointer only if it is not null. 
*/
#define DELETE_ARR(x) if (x != NULL) {delete[] x; x = NULL;}
#define CGTK_DELETE_ARR(x) if (x != NULL) {delete[] x; x = NULL;}

/*
** Defines accessors to an member variable of a class. 
** (read and write)
** NAME: Name after the Set and Get method (i.e. Set<NAME> Get<NAME>)
** DATA_TYPE: Data type of the system
** MEMBER_NAME: Name of the member
*/
#define DEF_MEMBER_RW(NAME, DATA_TYPE, MEMBER_NAME) \
    const DATA_TYPE & Get##NAME() {return MEMBER_NAME;} \
    void Set##NAME(const DATA_TYPE& val) {MEMBER_NAME = val;} 

/*
** Defines accessors to an array type member variable of a class. 
** (read and write)
*/
#define DEF_MEMBER_RW_ARR(NAME, DATA_TYPE, MEMBER_NAME) \
    const DATA_TYPE & Get##NAME(unsigned int i) {return MEMBER_NAME[i];} \
    void Set##NAME(unsigned int i, const DATA_TYPE& val) {MEMBER_NAME[i] = val;} 


 

#endif /* end of include guard: UTIL_H__ */