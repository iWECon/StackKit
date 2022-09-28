import UIKit

open class StackController: UIViewController {
    
    private(set) var bodyView: UIView
    
    public required init(body: () -> UIView) {
        self.bodyView = body()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(bodyView)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bodyView.frame = view.bounds
    }
    
}
