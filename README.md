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
            <Foo bar={
                () => {
                    console.log('oh no');
                    return <OhNo />;
                }
            }>
                <div>Hello</div>
                <div>{this.state.name}</div>
                <div>
                    <World big="true" blue={true}/>
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
                {
                    bar: () => {
                        console.log('oh no');
                        return React.createElement(OhNo);
                    }
                },
                React.createElement(
                    "div",
                    null,
                    Hello
                ),
                React.createElement(
                    "div",
                    null,
                    this.state.name
                ),
                React.createElement(
                    "div",
                    null,
                    React.createElement(
                        World,
                        {
                            big: "true",
                            blue: true
                        }
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
