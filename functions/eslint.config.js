import js from "@eslint/js";
import globals from "globals";

export default [
    js.configs.recommended,
    {
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                ...globals.node,
                ...globals.es2015,
            },
        },
        rules: {
            "no-restricted-globals": ["error", "name", "length"],
            "prefer-arrow-callback": "error",
            "quotes": ["error", "double", { "allowTemplateLiterals": true }],
            // Carry over fundamental google style rules if needed, 
            // but starting with recommended and custom rules for now.
        },
    },
    {
        files: ["**/*.spec.js"],
        languageOptions: {
            globals: {
                ...globals.mocha,
            },
        },
    },
];
