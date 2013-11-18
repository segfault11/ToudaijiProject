//
//  Shader.fsh
//  ToudaijiModelViewer
//
//  Created by Arno in Wolde Lübke on 15.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
