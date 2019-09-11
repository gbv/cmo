const path = require('path');

module.exports = {
    mode: 'production',
    entry: './src/main/typescript/search/cmo.ts',
    module: {
        rules: [
            {
                test: /\.tsx?$/,
                use: 'ts-loader',
                exclude: /node_modules/
            }
        ]
    },
    resolve: {
        extensions: [ '.ts', '.js' ]
    },
    output: {
        filename: 'cmo.bundle.js',
        path: path.resolve(__dirname, 'target/classes/META-INF/resources/js/')
    }
};