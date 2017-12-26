# JSX Transformer

A tool to convert JSX like syntax to appropiate pragma.  
The aim is to somehow be programming language agnostic and enable using JSX in any language

## Current progress
```jsx
<Foo name="Bob">
    <div>Hello</div>
    <div>
        <World />
    </div>
</Foo>
```
transforms to
```js
React.createElement(
    Foo,
    {name: Bob},
    React.createElement(
        div,
        null,
        Hello
    ),
    React.createElement(
        div,
        null,
        React.createElement(
            World,
            null,
        )
    )
)
```

## Roadmap
- [ ] Lowercased tagnames
- [ ] Quotes on attributes
- [ ] Code expressions within the JSX
- [x] Self closing tags
