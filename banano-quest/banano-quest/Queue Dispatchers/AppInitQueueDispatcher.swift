//
//  AppInitQueueDispatcher.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public class AppInitQueueDispatcher {
    
    private let operationQueue: OperationQueue = OperationQueue()
    private let downloadBalanceOperation: DownloadBalanceOperation
    private let transactionCountOperation: DownloadTransactionCountOperation
    private let questAmounOperation: DownloadQuestAmountOperation
    private let ethUsdPriceOperation: DownloadEthUsdPriceOperation
    
    public init(playerAddress: String, tavernAddress: String, bananoTokenAddress: String) {
        // Init operations
        self.downloadBalanceOperation = DownloadBalanceOperation.init(address: playerAddress)
        self.transactionCountOperation = DownloadTransactionCountOperation.init(address: playerAddress)
        self.questAmounOperation = DownloadQuestAmountOperation.init(tavernAddress: tavernAddress, tokenAddress: bananoTokenAddress)
        self.ethUsdPriceOperation = DownloadEthUsdPriceOperation.init()
        self.setOperationsCompletionBlocks()
    }
    
    public func dispatchSequence() {
        self.operationQueue.addOperations([self.downloadBalanceOperation, self.transactionCountOperation, self.questAmounOperation, self.ethUsdPriceOperation], waitUntilFinished: true)
    }
    
    // Private interfaces
    private func setOperationsCompletionBlocks() {
        self.downloadBalanceOperation.completionBlock = {
            if self.downloadBalanceOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: self.downloadBalanceOperation.balance, transactionCount: nil, questAmount: nil, ethUsdPrice: nil))
            }
        }
        
        self.transactionCountOperation.completionBlock = {
            if self.transactionCountOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: nil, transactionCount: self.transactionCountOperation.transactionCount, questAmount: nil, ethUsdPrice: nil))
            }
        }
        
        self.questAmounOperation.completionBlock = {
            if self.questAmounOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: nil, transactionCount: nil, questAmount: self.questAmounOperation.questAmount, ethUsdPrice: nil))
            }
        }
        
        self.ethUsdPriceOperation.completionBlock = {
            if self.ethUsdPriceOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: nil, transactionCount: nil, questAmount: nil, ethUsdPrice: self.ethUsdPriceOperation.usdPrice))
            }
        }
    }
    
}
