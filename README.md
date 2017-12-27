# JSX Transformer

A tool to convert JSX like syntax to appropiate pragma.  
The aim is to somehow be programming language agnostic and enable using JSX in any language

## Current progress
```jsx
import React, {Component} from 'react';

class MyComponent extends Component {
    state = {
        name: "Bob",
    };

    componentDidMount() {
        console.log("Component Did Mount!!");
        console.log(`test: ${<World />}`);
    }

    render() {
        return (
            <Foo name="Bob">
                <div>Hello</div>
                <div>
                    <World />
                </div>
            </Foo>
        );
    }
}
```
transforms to
```js
import React, {Component} from 'react';

class MyComponent extends Component {
    state = {
        name: "Bob",
    };

    componentDidMount() {
        console.log("Component Did Mount!!");
        console.log(`test: ${React.createElement(World)}`);
    }

    render() {
        return (
            React.createElement(
                Foo,
                {name:"Bob"},
                React.createElement(
                    "div",
                    null,
                    Hello
                ),
                React.createElement(
                    "div",
                    null,
                    React.createElement(
                        World
                    )
                )
            )
        );
    }
}
```

_Note: the indentation was manually added, formatting needs work_

## Roadmap
- [ ] Code expressions within the JSX
- [x] JSX in code
- [x] Quotes on attributes
- [x] Lowercased tagnames
- [x] Self closing tags
