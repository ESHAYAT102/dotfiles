import tseslint from 'typescript-eslint';
import stylisticTs from '@stylistic/eslint-plugin-ts'

export default [
	{
		files: ['**/*.ts'],
		plugins: {
			'@typescript-eslint': tseslint.plugin,
			'@stylistic/ts': stylisticTs
		},
		languageOptions: {
			sourceType: 'module',
			parser: tseslint.parser,
			parserOptions: {
				projectService: true,
				tsconfigRootDir: './',
				ecmaVersion: 2022
			}
		},
		rules: {
				'semi': 'off',
				'@stylistic/ts/semi': 'error',
				'@stylistic/ts/member-delimiter-style': ['error' ,{
					'multiline': {
					'delimiter': 'semi',
					'requireLast': true
					},
					'singleline': {
					'delimiter': 'semi',
					'requireLast': false
					},
					'multilineDetection': 'brackets'
				}],
				'indent': 'off',
				'@stylistic/ts/indent': ['warn', 'tab', { 'SwitchCase': 1 } ],
				//'@typescript-eslint/no-floating-promises': 'error',
				'@typescript-eslint/consistent-type-exports': 'error',
				'@typescript-eslint/naming-convention': [
					'warn',
					{
						'selector': 'class',
						'format': [
							'PascalCase'
						],
						'leadingUnderscore': 'allow'
					}
				],
				'no-extra-semi': 'warn',
				'curly': 'warn',
				'eqeqeq': 'error',
				'constructor-super': 'warn',
				'prefer-const': [
					'warn',
					{
						'destructuring': 'all'
					}
				],
				'no-buffer-constructor': 'warn',
				'no-caller': 'warn',
				'no-case-declarations': 'warn',
				'no-debugger': 'warn',
				'no-duplicate-case': 'warn',
				'no-duplicate-imports': 'warn',
				'no-eval': 'warn',
				//'no-async-promise-executor': 'warn',
				'no-new-wrappers': 'warn',
				'no-redeclare': 'off',
				'no-sparse-arrays': 'warn',
				'no-throw-literal': 'warn',
				'no-unsafe-finally': 'warn',
				'no-unused-labels': 'warn',
				'no-restricted-globals': [
					'warn',
					'name',
					'length',
					'event',
					'closed',
					'external',
					'status',
					'origin',
					'orientation',
					'context'
				],
				'no-var': 'warn'
		}
	}
];